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

A comprehensive script that collects and displays detailed system information with both **full** and **short** output modes.

### 🚀 Quick Start

```bash
# Full detailed report
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash

# Short compact report (easy to copy/paste)
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash -s -- --short
# or
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash -s -- -s
```

### 📊 Output Modes

#### Mode 1: Full Report (Default)
Comprehensive output with all details, perfect for deep analysis.

```bash
./system_report.sh
```

#### Mode 2: Short Report (`-s` or `--short`)
Compact, easy-to-read output perfect for:
- Copying into tickets or chat
- Quick status checks
- Email reports
- Monitoring dashboards

```bash
./system_report.sh --short
# or
./system_report.sh -s
```

### What It Shows

**In Full Mode:**
- **Disk Information**: Physical disks, partitions, mount points, usage statistics
- **Memory Usage**: RAM total, used, free, available, and swap usage with color alerts
- **CPU Details**: Model, cores, threads, sockets, frequency, real-time usage
- **System Load**: Load average (1,5,15 min) and top memory-consuming processes
- **GlusterFS Support**: Automatically detects and displays GlusterFS volumes with detailed status
- **Color Coding**: Green (normal), Yellow (warning), Red (critical)

**In Short Mode:**
- **Disk Layout**: Compact `lsblk` output showing partition hierarchy
- **Filesystem Usage**: Table of mount points with sizes and usage percentages
- **Memory & Swap**: One-line summaries with usage percentages
- **CPU Info**: Model, cores, load average, and usage percentage
- **GlusterFS**: Quick summary of GlusterFS mounts if present

### Usage Examples

```bash
# Basic full report
./system_report.sh

# Short compact report
./system_report.sh -s

# Save full report to file
./system_report.sh > report.txt

# Save short report to file
./system_report.sh -s > quick_status.txt

# Run on remote server (full)
ssh user@server 'curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash'

# Run on remote server (short)
ssh user@server 'curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash -s -- --short'

# Copy short report to clipboard (Linux)
./system_report.sh -s | xclip -selection clipboard

# Copy short report to clipboard (macOS)
./system_report.sh -s | pbcopy

# Watch system status in real-time (short mode every 5 seconds)
watch -n 5 './system_report.sh -s'
```

### Sample Outputs

#### Full Mode Output:
```
╔════════════════════════════════════════════════════════════════════════════╗
║                         SYSTEM INFORMATION REPORT                         ║
╚════════════════════════════════════════════════════════════════════════════╝

Generated on: 2026-04-30 14:30:22
Hostname: myserver
================================================================================

=== DISK, PARTITIONS & MOUNTPOINTS ===
Total Physical Disks: 2
Disk List:
  • sda 238.5G
  • sdb 931.5G

GlusterFS Detection:
  • Detected 1 GlusterFS mount(s)

Partitions and Mount Points:
FILESYSTEM                      SIZE       USED            AVAIL           USE%     MOUNTPOINT
--------------------------------------------------------------------------------------------------------
/dev/sda1                       100G       45G             55G             45%      /
/dev/sdb1                       900G       300G            600G            33%      /data
192.168.1.10:volume1            500G       200G            300G            40%      /mnt/glusterfs

=== MEMORY & SWAP UTILIZATION ===
RAM Information:
  • Total Memory: 15.6Gi
  • Used Memory: 8.2Gi
  • Free Memory: 7.4Gi
  • Available Memory: 9.1Gi
  • Usage Percentage: 52%

SWAP Information:
  • Total Swap: 2.0Gi
  • Used Swap: 0Gi
  • Free Swap: 2.0Gi
  • Usage Percentage: 0%

=== CPU INFORMATION ===
CPU Details:
  • CPU Model: Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz
  • Total Cores: 12
  • Threads per Core: 2
  • Sockets: 1
  • Cores per Socket: 12
  • CPU Frequency: 2600.000 MHz

=== SYSTEM LOAD & CPU USAGE ===
Load Average (1, 5, 15 min): 2.50, 2.30, 2.10
CPU Usage: 25%

System Uptime and Users:
  • 14:30:22 up 5 days, 3:22, 3 users, load average: 2.50, 2.30, 2.10

=== GLUSTERFS DETAILS ===
GlusterFS Volume Information:
  • 192.168.1.10:volume1 500G 200G 300G 40% /mnt/glusterfs

GlusterFS Volume Status:
  • Volume Name: volume1
  • Status: Started
  • Number of Bricks: 3

=== TOP 5 MEMORY-CONSUMING PROCESSES ===
Processes:
  • chrome                15.2% MEM - /opt/google/chrome/chrome
  • docker                12.1% MEM - /usr/bin/dockerd
  • mysql                 8.5% MEM  - /usr/sbin/mysqld

================================================================================
✓ Report Complete!
```

#### Short Mode Output (`-s`):
```
========================================
System Report - 2026-04-30 14:30:22
Host: myserver
========================================

[DISK, PARTITIONS & MOUNTPOINTS]
Disk Layout:
sda    238.5G disk
├─sda1 100G   part /
└─sda2 138.5G part [SWAP]
sdb    931.5G disk
└─sdb1 931.5G part /data

Filesystem Usage:
MOUNTPOINT                SIZE     USED     AVAIL    USE%
----------------------------------------------------------
/                         100G     45G      55G      45%
/data                     900G     300G     600G     33%
/mnt/glusterfs            500G     200G     300G     40%

[MEMORY & SWAP UTILIZATION]
RAM: 8.2Gi / 15.6Gi used | Available: 9.1Gi
Usage: 52%
SWAP: 0Gi / 2.0Gi used (0%)

[CPU INFORMATION]
CPU: Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz
Cores: 12

[SYSTEM LOAD & CPU USAGE]
Load Average: 2.50, 2.30, 2.10
CPU Usage: 25%

[GLUSTERFS DETAILS]
GlusterFS Mounts:
  192.168.1.10:volume1 @ /mnt/glusterfs (40% used)

----------------------------------------
✓ Report Complete - 14:30:25
```

### Requirements

- Linux or WSL
- Standard utilities: `df`, `free`, `lscpu`, `top`, `ps`, `lsblk`

### Color Legend

| Color | Meaning | Range |
|-------|---------|-------|
| 🟢 **Green** | Normal/Healthy | 0-74% usage |
| 🟡 **Yellow** | Warning | 75-89% usage |
| 🔴 **Red** | Critical | 90-100% usage |

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
```

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
```

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

### Create Convenient Aliases

Add these to your `~/.bashrc`:

```bash
# System report aliases
alias sysinfo='curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash'
alias sysinfo-short='curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash -s -- --short'

# VM checker alias
alias vm-check='~/scripts/check-vm-reserved-memory.sh'
```

---

## 🔧 Troubleshooting

<details>
<summary><b>Script 1: "command not found" errors</b></summary>

Install missing utilities:
```bash
# Ubuntu/Debian
sudo apt-get install coreutils procps util-linux

# RHEL/CentOS
sudo yum install coreutils procps-ng util-linux
```
</details>

<details>
<summary><b>Script 1: Short mode not working</b></summary>

Make sure you're using the latest version:
```bash
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | head -20
# Should show version with --short support
```
</details>

<details>
<summary><b>Script 2: "kubectl: command not found"</b></summary>

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
</details>

<details>
<summary><b>Script 2: "jq: command not found"</b></summary>

```bash
sudo apt-get install jq    # Ubuntu/Debian
sudo yum install jq        # RHEL/CentOS
```
</details>

---

## 🔒 Security

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
