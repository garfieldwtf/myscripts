#!/bin/bash

# Script: check-vm-reserved-memory.sh
# Description: Check Harvester VM reserved memory usage across the cluster
# Author: Generated for Harvester/KubeVirt environment
# Version: 2.1 (Fixed counter bug + Append detailed logs)

# Default values
WARNING_THRESHOLD_MB=200
DANGER_THRESHOLD_MB=800
LOG_BASE_DIR="/usr/local/oom-logs"
EXECUTION_LOG="${LOG_BASE_DIR}/execution.log"
QUIET_MODE=false
VERBOSE_MODE=false
SINGLE_VM=""

# Colors for console output (disabled in quiet mode)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to show help
show_help() {
    cat << EOF
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    Harvester VM Reserved Memory Checker                        ║
║                              Help & Usage Guide                                ║
╚═══════════════════════════════════════════════════════════════════════════════╝

SYNOPSIS
    ./check-vm-reserved-memory.sh [OPTIONS]

DESCRIPTION
    This script checks all Harvester VMs in the cluster for reserved memory usage.
    It identifies VMs whose sidecar container overhead exceeds configured thresholds
    and creates detailed logs for investigation and remediation.

    The script monitors the "guest-console-log" sidecar container which consumes
    the reserved memory configured via harvesterhci.io/reservedMemory annotation.

OPTIONS
    -w, --warning <MB>      Warning threshold in megabytes (default: 200)
                            VM overhead exceeding this value will trigger a WARNING.

    -d, --danger <MB>       Danger threshold in megabytes (default: 800)
                            VM overhead exceeding this value will trigger DANGER.

    -l, --log-dir <path>    Directory for log files (default: /usr/local/oom-logs)
                            Creates execution.log and individual VM logs.

    -n, --namespace <ns>    Check only VMs in specific namespace.

    -v, --vm <name>         Check only a specific VM (requires --namespace).

    -q, --quiet             Quiet mode - no console output (useful for cron jobs).

    --verbose               Verbose mode - show detailed debug information.

    -h, --help              Show this help message and exit.

THRESHOLD LOGIC
    The script calculates overhead as the memory usage of the guest-console-log
    container (the only sidecar that actively consumes reserved memory).

    Status determination:
    - OK:       Overhead ≤ Warning threshold
    - WARNING:  Warning threshold < Overhead ≤ Danger threshold
    - DANGER:   Overhead > Danger threshold

LOG FILES
    Execution log:     ${LOG_BASE_DIR}/execution.log (one line per scan, compact)
    VM detail logs:    ${LOG_BASE_DIR}/<vm-hostname>.log (appends for WARNING/DANGER)

EXAMPLES
    # Basic usage with default thresholds (200MB warning, 800MB danger)
    ./check-vm-reserved-memory.sh

    # Custom thresholds (100MB warning, 500MB danger)
    ./check-vm-reserved-memory.sh -w 100 -d 500

    # Check only VMs in specific namespace
    ./check-vm-reserved-memory.sh -n portal-innodb

    # Check a specific VM
    ./check-vm-reserved-memory.sh -n portal-innodb -v sn1ylvx1a0056

    # Quiet mode for cron (no console output, still writes logs)
    ./check-vm-reserved-memory.sh -q

    # Verbose mode for debugging
    ./check-vm-reserved-memory.sh --verbose -w 150 -d 600

    # Custom log directory
    ./check-vm-reserved-memory.sh -l /var/log/vm-monitor -w 300 -d 1000

CRON JOB EXAMPLES
    # Run every 5 minutes (quiet mode)
    */5 * * * * /usr/local/bin/check-vm-reserved-memory.sh -q

    # Run hourly with custom thresholds
    0 * * * * /usr/local/bin/check-vm-reserved-memory.sh -w 200 -d 800 -q

    # Run daily at 2 AM with verbose logging to file
    0 2 * * * /usr/local/bin/check-vm-reserved-memory.sh --verbose >> /var/log/vm-check.log 2>&1

NOTES
    - The script requires: kubectl, jq
    - Metrics-server must be running for accurate memory usage
    - Init containers are NOT included in overhead calculation (they are completed)
    - Reserved memory configured via: harvesterhci.io/reservedMemory annotation

EXIT CODES
    0   - Success, no issues found
    1   - Error (missing dependencies, connectivity issues)
    2   - WARNING threshold exceeded (at least one VM)
    3   - DANGER threshold exceeded (at least one VM)

EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--warning)
            WARNING_THRESHOLD_MB="$2"
            shift 2
            ;;
        -d|--danger)
            DANGER_THRESHOLD_MB="$2"
            shift 2
            ;;
        -l|--log-dir)
            LOG_BASE_DIR="$2"
            EXECUTION_LOG="${LOG_BASE_DIR}/execution.log"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE_FILTER="$2"
            shift 2
            ;;
        -v|--vm)
            SINGLE_VM="$2"
            shift 2
            ;;
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        --verbose)
            VERBOSE_MODE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check for required dependencies
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required but not installed." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not installed." >&2; exit 1; }

# Disable colors in quiet mode
if [ "$QUIET_MODE" = true ]; then
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; MAGENTA=''; NC=''
fi

# Create log directory
mkdir -p "$LOG_BASE_DIR"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Initialize counters
TOTAL_VMS=0
VMS_ABOVE_WARNING=0
VMS_ABOVE_DANGER=0
VMS_WITH_NO_RESERVED=0
VMS_NOT_RUNNING=0

# Start execution log
echo "==========================================" >> "$EXECUTION_LOG"
echo "Scan: $TIMESTAMP" >> "$EXECUTION_LOG"
echo "Warning: ${WARNING_THRESHOLD_MB}MB, Danger: ${DANGER_THRESHOLD_MB}MB" >> "$EXECUTION_LOG"
if [ -n "$NAMESPACE_FILTER" ]; then
    echo "Filter: namespace=$NAMESPACE_FILTER" >> "$EXECUTION_LOG"
fi
if [ -n "$SINGLE_VM" ]; then
    echo "Filter: vm=$SINGLE_VM" >> "$EXECUTION_LOG"
fi
echo "==========================================" >> "$EXECUTION_LOG"

# Console output (unless quiet mode)
if [ "$QUIET_MODE" = false ]; then
    echo "=========================================="
    echo "VM Reserved Memory Checker"
    echo "=========================================="
    echo "Time: $TIMESTAMP"
    echo "Warning Threshold: ${WARNING_THRESHOLD_MB} MB"
    echo "Danger Threshold:  ${DANGER_THRESHOLD_MB} MB"
    if [ -n "$NAMESPACE_FILTER" ]; then
        echo "Namespace Filter: $NAMESPACE_FILTER"
    fi
    if [ -n "$SINGLE_VM" ]; then
        echo "VM Filter: $SINGLE_VM"
    fi
    echo "Log Directory: $LOG_BASE_DIR"
    echo "=========================================="
    echo ""
fi

# Build VM list query
if [ -n "$NAMESPACE_FILTER" ] && [ -n "$SINGLE_VM" ]; then
    # Single VM in specific namespace
    VM_LIST=$(kubectl get vm -n "$NAMESPACE_FILTER" "$SINGLE_VM" -o json 2>/dev/null | jq -r '{"items": [.]} | .items[]? | "\(.metadata.namespace) \(.metadata.name)"' 2>/dev/null)
    if [ -z "$VM_LIST" ]; then
        if [ "$QUIET_MODE" = false ]; then
            echo -e "${RED}Error: VM '$SINGLE_VM' not found in namespace '$NAMESPACE_FILTER'${NC}"
        fi
        exit 1
    fi
elif [ -n "$NAMESPACE_FILTER" ]; then
    # All VMs in specific namespace
    VM_LIST=$(kubectl get vm -n "$NAMESPACE_FILTER" -o json 2>/dev/null | jq -r '.items[]? | "\(.metadata.namespace) \(.metadata.name)"' 2>/dev/null)
else
    # All VMs across all namespaces
    VM_LIST=$(kubectl get vm --all-namespaces -o json 2>/dev/null | jq -r '.items[]? | "\(.metadata.namespace) \(.metadata.name)"' 2>/dev/null)
fi

if [ -z "$VM_LIST" ]; then
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${YELLOW}No VMs found in cluster${NC}"
    fi
    echo "No VMs found" >> "$EXECUTION_LOG"
    exit 0
fi

# Use a temporary file to avoid subshell variable scope issue
VM_LIST_FILE=$(mktemp)
echo "$VM_LIST" > "$VM_LIST_FILE"

# Process each VM
while IFS= read -r line; do
    [ -z "$line" ] && continue
    NAMESPACE=$(echo "$line" | awk '{print $1}')
    VM_NAME=$(echo "$line" | awk '{print $2}')

    TOTAL_VMS=$((TOTAL_VMS + 1))

    if [ "$QUIET_MODE" = false ]; then
        echo -e "${BLUE}Checking: $NAMESPACE/$VM_NAME${NC}"
    fi

    # Find the virt-launcher pod
    POD_NAME=$(kubectl get pods -n "$NAMESPACE" 2>/dev/null | grep "^virt-launcher-$VM_NAME-" | awk '{print $1}' | head -1)

    if [ -z "$POD_NAME" ]; then
        if [ "$QUIET_MODE" = false ]; then
            echo -e "${YELLOW}  ⚠️  VM not running${NC}"
        fi
        VMS_NOT_RUNNING=$((VMS_NOT_RUNNING + 1))
        echo "  $NAMESPACE/$VM_NAME: NOT RUNNING" >> "$EXECUTION_LOG"
        [ "$QUIET_MODE" = false ] && echo ""
        continue
    fi

    # Get reserved memory
    RESERVED_MEMORY=$(kubectl get vm "$VM_NAME" -n "$NAMESPACE" -o yaml 2>/dev/null | grep "harvesterhci.io/reservedMemory:" | head -1 | awk '{print $2}' | tr -d '"')
    [ -z "$RESERVED_MEMORY" ] && RESERVED_MEMORY="Not Set" && VMS_WITH_NO_RESERVED=$((VMS_WITH_NO_RESERVED + 1))

    # Get VM guest memory
    GUEST_MEMORY=$(kubectl get vm "$VM_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.domain.memory.guest}' 2>/dev/null)

    # Get VM hostname
    VM_HOSTNAME=$(kubectl get vm "$VM_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.template.spec.hostname}' 2>/dev/null)
    [ -z "$VM_HOSTNAME" ] && VM_HOSTNAME="$VM_NAME"

    # Get total pod memory
    TOTAL_POD_MEMORY=$(kubectl top pod -n "$NAMESPACE" "$POD_NAME" --no-headers 2>/dev/null | awk '{print $3, $4}')

    # Get container metrics (only running containers)
    CONTAINER_METRICS=$(kubectl top pod -n "$NAMESPACE" "$POD_NAME" --containers 2>/dev/null)

    # Parse guest-console-log memory usage (this is the only sidecar using reserved memory)
    SIDECAR_MB=0
    SIDECAR_USAGE=""

    while IFS= read -r metric_line; do
        cont_name=$(echo "$metric_line" | awk '{print $2}')
        if [ "$cont_name" = "guest-console-log" ]; then
            mem_usage=$(echo "$metric_line" | awk '{print $4}')
            mem_unit=$(echo "$metric_line" | awk '{print $5}')
            SIDECAR_USAGE="${mem_usage}${mem_unit}"

            # Convert to MB
            if [[ "$mem_usage" =~ ^([0-9]+)$ ]] && [ "$mem_unit" = "Mi" ]; then
                SIDECAR_MB="$mem_usage"
            elif [[ "$mem_usage" =~ ^([0-9]+)Mi$ ]]; then
                SIDECAR_MB="${BASH_REMATCH[1]}"
            elif [[ "$mem_usage" =~ ^([0-9]+)$ ]] && [ "$mem_unit" = "Gi" ]; then
                SIDECAR_MB=$((mem_usage * 1024))
            fi
            break
        fi
    done <<< "$CONTAINER_METRICS"

    # Determine status
    STATUS="OK"
    STATUS_COLOR="$GREEN"
    STATUS_TEXT="OK"
    if [ "$SIDECAR_MB" -gt "$DANGER_THRESHOLD_MB" ]; then
        STATUS="DANGER"
        STATUS_COLOR="$RED"
        STATUS_TEXT="DANGER"
        VMS_ABOVE_DANGER=$((VMS_ABOVE_DANGER + 1))
        VMS_ABOVE_WARNING=$((VMS_ABOVE_WARNING + 1))
    elif [ "$SIDECAR_MB" -gt "$WARNING_THRESHOLD_MB" ]; then
        STATUS="WARNING"
        STATUS_COLOR="$YELLOW"
        STATUS_TEXT="WARNING"
        VMS_ABOVE_WARNING=$((VMS_ABOVE_WARNING + 1))
    fi

    # Console output
    if [ "$QUIET_MODE" = false ]; then
        echo "  Pod: $POD_NAME"
        echo "  Reserved Memory: $RESERVED_MEMORY"
        echo "  VM Guest Memory: $GUEST_MEMORY"
        echo "  Total Pod Memory: $TOTAL_POD_MEMORY"
        echo ""
        echo "  Sidecar (guest-console-log) Usage: $SIDECAR_USAGE"
        echo "  Sidecar Count: 1 | Total Overhead: ${SIDECAR_MB} MB"
        echo -e "  Status: ${STATUS_COLOR}${STATUS_TEXT}${NC}"
        echo ""

        if [ "$VERBOSE_MODE" = true ]; then
            echo "  [DEBUG] Pod: $POD_NAME"
            echo "  [DEBUG] Namespace: $NAMESPACE"
            echo "  [DEBUG] Container metrics:"
            echo "$CONTAINER_METRICS" | while read line; do echo "    $line"; done
            echo ""
        fi
    fi

    # Write to execution log (one line per VM)
    echo "$NAMESPACE/$VM_NAME: overhead=${SIDECAR_MB}MB, sidecars=1, status=$STATUS_TEXT, reserved=$RESERVED_MEMORY" >> "$EXECUTION_LOG"

    # Create detailed log only for WARNING or DANGER (APPEND mode)
    if [ "$STATUS" = "WARNING" ] || [ "$STATUS" = "DANGER" ]; then
        DETAIL_LOG="${LOG_BASE_DIR}/${VM_HOSTNAME}.log"

        # Get JSON output for all containers
        JSON_OUTPUT=$(kubectl get pod -n "$NAMESPACE" "$POD_NAME" -o json 2>/dev/null | jq -r '
            .spec.containers[]? |
            {
                pod: "'"$POD_NAME"'",
                namespace: "'"$NAMESPACE"'",
                container: .name,
                mem_request: (.resources.requests.memory // "N/A"),
                mem_limit: (.resources.limits.memory // "N/A")
            }' 2>/dev/null)

        # Append to detailed log with timestamp separator
        echo "" >> "$DETAIL_LOG"
        echo "================================================================================" >> "$DETAIL_LOG"
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] STATUS: ${STATUS} - VM: $VM_NAME" >> "$DETAIL_LOG"
        echo "================================================================================" >> "$DETAIL_LOG"

        cat >> "$DETAIL_LOG" << EOF
VM: $VM_NAME
Namespace: $NAMESPACE
Hostname: $VM_HOSTNAME
Status: ${STATUS}

THRESHOLDS:
================================================================================
Warning Threshold: ${WARNING_THRESHOLD_MB} MB
Danger Threshold:  ${DANGER_THRESHOLD_MB} MB

VM CONFIGURATION:
================================================================================
Guest Memory (allocated): $GUEST_MEMORY
Reserved Memory Config:   $RESERVED_MEMORY

POD INFORMATION:
================================================================================
Pod Name: $POD_NAME
Total Pod Memory: $TOTAL_POD_MEMORY

SIDECAR OVERHEAD:
================================================================================
Container: guest-console-log
Memory Usage: $SIDECAR_USAGE (${SIDECAR_MB} MB)

TOTAL OVERHEAD: ${SIDECAR_MB} MB

STATUS ANALYSIS:
================================================================================
Current Overhead: ${SIDECAR_MB} MB
Warning Threshold: ${WARNING_THRESHOLD_MB} MB
Danger Threshold:  ${DANGER_THRESHOLD_MB} MB
Status: ${STATUS}

CONTAINER SPECS (JSON format):
================================================================================
$JSON_OUTPUT

EOF

        if [ "$STATUS" = "DANGER" ]; then
            cat >> "$DETAIL_LOG" << EOF
RECOMMENDATIONS (CRITICAL):
================================================================================
⚠️  VM IN DANGER STATE - IMMEDIATE ACTION REQUIRED!

Increase reserved memory:
kubectl annotate vm $VM_NAME -n $NAMESPACE harvesterhci.io/reservedMemory="$((SIDECAR_MB + 500))Mi" --overwrite

Current: $RESERVED_MEMORY
Recommended: $((SIDECAR_MB + 500))Mi

Check for memory leaks:
- Log into VM and run: free -h
- Check processes: top or htop
- Review VM workload for unusual memory consumption
EOF
        else
            cat >> "$DETAIL_LOG" << EOF
RECOMMENDATIONS (WARNING):
================================================================================
Consider increasing reserved memory:
kubectl annotate vm $VM_NAME -n $NAMESPACE harvesterhci.io/reservedMemory="$((SIDECAR_MB + 200))Mi" --overwrite

Current: $RESERVED_MEMORY
Recommended: $((SIDECAR_MB + 200))Mi

Monitor this VM for memory growth over time.
EOF
        fi

        echo "" >> "$DETAIL_LOG"

        if [ "$QUIET_MODE" = false ]; then
            echo -e "  ${YELLOW}📝 Detailed log appended: $DETAIL_LOG${NC}"
        fi
        echo "  Detailed log appended: $DETAIL_LOG" >> "$EXECUTION_LOG"
    fi

done < "$VM_LIST_FILE"

# Clean up temp file
rm -f "$VM_LIST_FILE"

# Write summary to execution log
echo "" >> "$EXECUTION_LOG"
echo "Summary: Total=$TOTAL_VMS, Warning=$VMS_ABOVE_WARNING, Danger=$VMS_ABOVE_DANGER, NoReserved=$VMS_WITH_NO_RESERVED, NotRunning=$VMS_NOT_RUNNING" >> "$EXECUTION_LOG"
echo "==========================================" >> "$EXECUTION_LOG"
echo "" >> "$EXECUTION_LOG"

# Console summary
if [ "$QUIET_MODE" = false ]; then
    echo "=========================================="
    echo "SCAN COMPLETE"
    echo "=========================================="
    echo "Total VMs scanned:     $TOTAL_VMS"
    echo "WARNING threshold:     $VMS_ABOVE_WARNING (${WARNING_THRESHOLD_MB}MB)"
    echo "DANGER threshold:      $VMS_ABOVE_DANGER (${DANGER_THRESHOLD_MB}MB)"
    echo "No reserved config:    $VMS_WITH_NO_RESERVED"
    echo "VMs not running:       $VMS_NOT_RUNNING"
    echo ""
    echo "Execution log: $EXECUTION_LOG"
    if [ $VMS_ABOVE_WARNING -gt 0 ] || [ $VMS_ABOVE_DANGER -gt 0 ]; then
        echo "Detail logs:   $LOG_BASE_DIR/*.log"
    fi
    echo "=========================================="
fi

# Exit with appropriate code
if [ $VMS_ABOVE_DANGER -gt 0 ]; then
    exit 3
elif [ $VMS_ABOVE_WARNING -gt 0 ]; then
    exit 2
else
    exit 0
fi
