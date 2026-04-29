# 🖥️ Linux System Administration Scripts

Collection of useful bash scripts for system monitoring and Kubernetes/Harvester VM management.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Version](https://img.shields.io/badge/Bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)

---

## 📋 Script Index

- [Section 1: System Information Report](#section-1-system-information-report)
- [Section 2: Harvester VM Reserved Memory Checker](#section-2-harvester-vm-reserved-memory-checker)

---

## Section 1: System Information Report

A comprehensive script that collects and displays detailed system information.

### Quick Start

```bash
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash
```

### What It Shows

- **Disk Information**: Partitions, mount points, usage statistics
- **Memory Usage**: RAM total, used, available, and swap usage  
- **CPU Details**: Model, cores, frequency, real-time usage
- **System Load**: Load average and top memory-consuming processes

### Usage Examples

```bash
# Basic run
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash

# Save to file
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash > system_report.txt

# Run on remote server
ssh user@server 'curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash'
```

### Sample Output

```
=== DISK, PARTITIONS & MOUNTPOINTS ===
/dev/sda1        100G   45G   55G   45%   /
/dev/sdb1        900G  300G  600G   33%   /data

=== MEMORY & SWAP UTILIZATION ===
Total Memory: 15.6Gi
Used Memory: 8.2Gi
Usage Percentage: 52%

=== CPU INFORMATION ===
CPU Model: Intel Core i7-10750H
Total Cores: 12
CPU Usage: 25%
```

### Requirements

- Linux or WSL
- Standard utilities: `df`, `free`, `lscpu`, `top`, `ps`

---

## Section 2: Harvester VM Reserved Memory Checker

Monitors VM reserved memory usage in Harvester/KubeVirt clusters and alerts when thresholds are exceeded.

### Quick Start

```bash
# Download the script
curl -O https://garfieldwtf.github.io/myscripts/check-vm-reserved-memory.sh
chmod +x check-vm-reserved-memory.sh

# Run it
./check-vm-reserved-memory.sh
```

### What It Does

- Scans all VMs in your Harvester cluster
- Monitors `guest-console-log` sidecar memory usage
- Identifies VMs exceeding warning/danger thresholds
- Creates detailed logs with remediation commands

### Requirements

- `kubectl` configured for your Harvester cluster
- `jq` installed
- Metrics-server running in the cluster

### Command Options

| Option | Description | Default |
|--------|-------------|---------|
| `-w, --warning <MB>` | Warning threshold in MB | 200 |
| `-d, --danger <MB>` | Danger threshold in MB | 800 |
| `-n, --namespace <ns>` | Check only specific namespace | All namespaces |
| `-v, --vm <name>` | Check only specific VM | All VMs |
| `-q, --quiet` | No console output (for cron) | Off |
| `-l, --log-dir <path>` | Directory for logs | `/usr/local/oom-logs` |
| `--verbose` | Show debug information | Off |
| `-h, --help` | Show help menu | - |

### Usage Examples

```bash
# Basic check with default thresholds
./check-vm-reserved-memory.sh

# Custom thresholds (100MB warning, 500MB danger)
./check-vm-reserved-memory.sh -w 100 -d 500

# Check only production namespace
./check-vm-reserved-memory.sh -n production

# Check a specific VM
./check-vm-reserved-memory.sh -n production -v web-server-01

# Quiet mode for cron jobs
./check-vm-reserved-memory.sh -q -w 150 -d 600

# Custom log directory
./check-vm-reserved-memory.sh -l /var/log/vm-monitor
```

### Understanding the Output

The script categorizes VMs into three states:

- **OK** (🟢 Green): Overhead ≤ Warning threshold
- **WARNING** (🟡 Yellow): Warning < Overhead ≤ Danger  
- **DANGER** (🔴 Red): Overhead > Danger threshold

### Log Files

The script creates two types of logs:

**1. Execution Log** (`/usr/local/oom-logs/execution.log`)
```
Scan: 2026-04-29 14:30:22
production/web-01: overhead=250MB, status=WARNING
production/db-01: overhead=850MB, status=DANGER
Summary: Total=10, Warning=1, Danger=1
```

**2. VM Detail Logs** (`/usr/local/oom-logs/<vm-hostname>.log`)
- Created only for WARNING/DANGER VMs
- Includes VM configuration, container specs, and fix recommendations

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - no issues found |
| 1 | Error (missing dependencies, connectivity) |
| 2 | WARNING threshold exceeded |
| 3 | DANGER threshold exceeded |

### Cron Job Setup

```bash
# Run every 5 minutes
*/5 * * * * /usr/local/bin/check-vm-reserved-memory.sh -q

# Run hourly with custom thresholds
0 * * * * /usr/local/bin/check-vm-reserved-memory.sh -w 200 -d 800 -q

# Run daily at 2 AM with verbose logging
0 2 * * * /usr/local/bin/check-vm-reserved-memory.sh --verbose >> /var/log/vm-check.log 2>&1
```

### Fix Recommendations

When a VM enters WARNING or DANGER state, the script provides kubectl commands to increase reserved memory:

```bash
# For WARNING state
kubectl annotate vm <vm-name> -n <namespace> \
  harvesterhci.io/reservedMemory="<current+200>Mi" --overwrite

# For DANGER state  
kubectl annotate vm <vm-name> -n <namespace> \
  harvesterhci.io/reservedMemory="<current+500>Mi" --overwrite
```

### Troubleshooting

<details>
<summary><b>kubectl: command not found</b></summary>

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
</details>

<details>
<summary><b>jq: command not found</b></summary>

```bash
sudo apt-get install jq    # Ubuntu/Debian
sudo yum install jq        # RHEL/CentOS
```
</details>

<details>
<summary><b>No VMs found</b></summary>

```bash
# Verify kubectl connectivity
kubectl cluster-info
kubectl get vm --all-namespaces
```
</details>

---

## 📦 Download Both Scripts

```bash
# Create scripts directory
mkdir -p ~/scripts && cd ~/scripts

# Download both scripts
curl -O https://garfieldwtf.github.io/myscripts/system_report.sh
curl -O https://garfieldwtf.github.io/myscripts/check-vm-reserved-memory.sh

# Make executable
chmod +x *.sh

# Optional: Add to PATH
echo 'export PATH="$HOME/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🔒 Security Notes

Both scripts are **read-only** and:
- Make no system changes
- Don't send data externally
- Don't require root privileges
- Are fully open source for review

---

## 📄 License

MIT License - Free to use, modify, and distribute.

---

## ⭐ Support

If these scripts help you, please star the repository!

[![Star on GitHub](https://img.shields.io/github/stars/garfieldwtf/myscripts.svg?style=social)](https://github.com/garfieldwtf/myscripts/stargazers)

---

**Questions or issues?** [Open a GitHub issue](https://github.com/garfieldwtf/myscripts/issues)
