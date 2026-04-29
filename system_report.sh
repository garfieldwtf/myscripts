#!/bin/bash

# Script to collect system information - CLEAN VERSION without color code issues

# Only use colors for headers and non-tabular data, and ensure they don't leak into data
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    BOLD='\033[1m'
    BOLD_OFF='\033[22m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; NC=''; BOLD=''; BOLD_OFF=''
fi

# Function to draw a separator line
draw_line() {
    printf "%80s\n" | tr ' ' '='
}

# Function to print section header
print_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}"
}

# Function to print colored value safely
print_colored_value() {
    local label=$1
    local value=$2
    local percent=$3
    local color=$GREEN
    
    if [ $percent -ge 90 ]; then
        color=$RED
    elif [ $percent -ge 75 ]; then
        color=$YELLOW
    fi
    
    echo -e "  ${YELLOW}${label}:${NC} ${color}${value}${NC}"
}

# Start of report
clear
echo -e "${BOLD}${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                         SYSTEM INFORMATION REPORT                         ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "Hostname: $(hostname)"
draw_line

# 1. DISK AND PARTITION INFORMATION
print_header "DISK, PARTITIONS & MOUNTPOINTS"

# Number of disks
disk_count=$(lsblk -d -n -o NAME,TYPE 2>/dev/null | grep -c "disk" || echo "0")
echo -e "${YELLOW}Total Physical Disks:${NC} $disk_count"

if [ $disk_count -gt 0 ]; then
    echo -e "${YELLOW}Disk List:${NC}"
    lsblk -d -n -o NAME,SIZE,MODEL 2>/dev/null | head -20 | while read line; do
        echo "  • $line"
    done
else
    echo "  • No physical disks detected (virtualized environment)"
fi

# Partitions and mount points - COMPLETELY PLAIN TEXT
echo -e "\n${YELLOW}Partitions and Mount Points:${NC}"
printf "%-30s %-10s %-15s %-15s %-8s %s\n" "FILESYSTEM" "SIZE" "USED" "AVAIL" "USE%" "MOUNTPOINT"
echo "--------------------------------------------------------------------------------------------------------"

# Use df without any formatting that could add color codes
df -h -x tmpfs -x devtmpfs -x squashfs -x overlay 2>/dev/null | tail -n +2 | while read filesystem size used avail use_percent mount; do
    # Skip if mount point is empty or weird
    if [ -z "$mount" ] || [ "$mount" = "on" ]; then
        continue
    fi
    
    # Clean up the mount point (take first field only)
    mount=$(echo "$mount" | awk '{print $1}')
    
    # Skip snap and loop devices to reduce clutter
    if [[ "$filesystem" == *"snap"* ]] || [[ "$filesystem" == *"loop"* ]]; then
        continue
    fi
    
    # Skip if filesystem is 'none' or 'tmpfs' or 'rootfs'
    if [ "$filesystem" = "none" ] || [ "$filesystem" = "tmpfs" ] || [ "$filesystem" = "rootfs" ]; then
        continue
    fi
    
    # Format percentage for display (plain text)
    printf "%-30s %-10s %-15s %-15s %-8s %s\n" "$filesystem" "$size" "$used" "$avail" "$use_percent" "$mount"
done

# 2. MEMORY INFORMATION (including swap)
print_header "MEMORY & SWAP UTILIZATION"

# Get memory info - PLAIN TEXT (no colors)
mem_total=$(free -h | awk '/^Mem:/ {print $2}')
mem_used=$(free -h | awk '/^Mem:/ {print $3}')
mem_free=$(free -h | awk '/^Mem:/ {print $4}')
mem_available=$(free -h | awk '/^Mem:/ {print $7}')

# Calculate percentage from raw numbers
mem_total_raw=$(free -k | awk '/^Mem:/ {print $2}')
mem_used_raw=$(free -k | awk '/^Mem:/ {print $3}')

if [ $mem_total_raw -gt 0 ]; then
    mem_usage_percent=$((mem_used_raw * 100 / mem_total_raw))
else
    mem_usage_percent=0
fi

echo -e "${YELLOW}RAM Information:${NC}"
echo "  • Total Memory: ${mem_total}"
echo "  • Used Memory: ${mem_used}"
echo "  • Free Memory: ${mem_free}"
echo "  • Available Memory: ${mem_available}"

# Color only the percentage value
if [ $mem_usage_percent -ge 90 ]; then
    mem_color=$RED
elif [ $mem_usage_percent -ge 75 ]; then
    mem_color=$YELLOW
else
    mem_color=$GREEN
fi
echo -e "  • Usage Percentage: ${mem_color}${mem_usage_percent}%${NC}"

# SWAP Information
swap_total=$(free -h | awk '/^Swap:/ {print $2}')
swap_used=$(free -h | awk '/^Swap:/ {print $3}')
swap_free=$(free -h | awk '/^Swap:/ {print $4}')

swap_total_raw=$(free -k | awk '/^Swap:/ {print $2}')
swap_used_raw=$(free -k | awk '/^Swap:/ {print $3}')

if [ $swap_total_raw -gt 0 ]; then
    swap_usage_percent=$((swap_used_raw * 100 / swap_total_raw))
    
    echo -e "\n${YELLOW}SWAP Information:${NC}"
    echo "  • Total Swap: ${swap_total}"
    echo "  • Used Swap: ${swap_used}"
    echo "  • Free Swap: ${swap_free}"
    
    if [ $swap_usage_percent -ge 50 ]; then
        swap_color=$YELLOW
    else
        swap_color=$GREEN
    fi
    echo -e "  • Usage Percentage: ${swap_color}${swap_usage_percent}%${NC}"
else
    echo -e "\n${YELLOW}SWAP Information:${NC}"
    echo "  • No swap configured"
fi

# 3. CPU INFORMATION
print_header "CPU INFORMATION"

# CPU Model
cpu_model=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | sed 's/^[ \t]*//')
if [ -z "$cpu_model" ]; then
    cpu_model=$(lscpu 2>/dev/null | grep "^CPU:" | cut -d':' -f2 | sed 's/^[ \t]*//')
fi

if [ -z "$cpu_model" ]; then
    cpu_model="Unknown (virtualized environment)"
fi

echo -e "${YELLOW}CPU Details:${NC}"
echo "  • CPU Model: ${cpu_model}"

# CPU Cores
if command -v nproc &> /dev/null; then
    cpu_cores=$(nproc)
else
    cpu_cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "Unknown")
fi

cpu_threads=$(lscpu 2>/dev/null | grep "Thread(s) per core" | awk '{print $4}')
cpu_sockets=$(lscpu 2>/dev/null | grep "Socket(s)" | awk '{print $2}')
cpu_cores_per_socket=$(lscpu 2>/dev/null | grep "Core(s) per socket" | awk '{print $4}')

echo "  • Total Cores: ${cpu_cores}"
[ -n "$cpu_threads" ] && [ "$cpu_threads" != "" ] && echo "  • Threads per Core: ${cpu_threads}"
[ -n "$cpu_sockets" ] && [ "$cpu_sockets" != "" ] && echo "  • Sockets: ${cpu_sockets}"
[ -n "$cpu_cores_per_socket" ] && [ "$cpu_cores_per_socket" != "" ] && echo "  • Cores per Socket: ${cpu_cores_per_socket}"

# CPU Frequency
cpu_mhz=$(lscpu 2>/dev/null | grep "CPU MHz" | awk '{print $3}')
if [ -n "$cpu_mhz" ]; then
    echo "  • CPU Frequency: ${cpu_mhz} MHz"
fi

# Load Average and CPU Usage
print_header "SYSTEM LOAD & CPU USAGE"

# Load Average
load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')
echo -e "${YELLOW}Load Average (1, 5, 15 min):${NC} ${load_avg}"

# Get CPU usage percentage - using /proc/stat for accuracy
cpu_usage="N/A"

if [ -f /proc/stat ]; then
    # Read first sample
    read cpu_line1 < <(grep '^cpu ' /proc/stat)
    sleep 1
    # Read second sample
    read cpu_line2 < <(grep '^cpu ' /proc/stat)
    
    # Parse values
    cpu1=($cpu_line1)
    cpu2=($cpu_line2)
    
    # Calculate totals
    total1=0
    total2=0
    for i in {1..8}; do
        total1=$((total1 + ${cpu1[$i]}))
        total2=$((total2 + ${cpu2[$i]}))
    done
    
    # Idle is field 5 (index 4 in zero-based)
    idle1=${cpu1[4]}
    idle2=${cpu2[4]}
    
    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))
    
    if [ $total_diff -gt 0 ]; then
        cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))
    fi
fi

if [ "$cpu_usage" != "N/A" ] && [ "$cpu_usage" -ge 0 ]; then
    if [ $cpu_usage -ge 80 ]; then
        cpu_color=$RED
    elif [ $cpu_usage -ge 50 ]; then
        cpu_color=$YELLOW
    else
        cpu_color=$GREEN
    fi
    echo -e "${YELLOW}CPU Usage:${NC} ${cpu_color}${cpu_usage}%${NC}"
else
    echo -e "${YELLOW}CPU Usage:${NC} Unable to calculate"
fi

# System uptime and users
echo -e "\n${YELLOW}System Uptime and Users:${NC}"
uptime_info=$(uptime | sed 's/^[ \t]*//')
echo "  • ${uptime_info}"

# Optional: Show disk usage summary for important mount points
echo -e "\n${YELLOW}Top 5 Largest Filesystems by Usage:${NC}"
df -h -x tmpfs -x devtmpfs -x squashfs -x overlay 2>/dev/null | tail -n +2 | \
    grep -v "snap" | grep -v "loop" | \
    sort -k5 -rn | head -5 | \
    awk '{printf "  • %-15s %5s used on %s\n", $1, $5, $6}'

# Draw final line
draw_line
echo -e "${BOLD}${GREEN}✓ Report Complete!${NC}\n"
