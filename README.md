<div align="center">

# 🖥️ System Information Report Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Version](https://img.shields.io/badge/Bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![WSL](https://img.shields.io/badge/WSL-Compatible-0a5c89.svg)](https://docs.microsoft.com/en-us/windows/wsl/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**A comprehensive, colorful bash script that gives you instant insights into your system's health and performance**

[Quick Start](#-quick-start) • [Features](#-features) • [Usage](#-usage) • [Screenshots](#-screenshots) • [Customization](#-customization)

</div>

---

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Usage Examples](#-usage-examples)
- [System Requirements](#-system-requirements)
- [Output Breakdown](#-output-breakdown)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)
- [Security](#-security)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🚀 Quick Start

### One-liner (Run instantly - no installation required!)

```bash
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash
```

### Or with wget

```bash
wget -qO- https://garfieldwtf.github.io/myscripts/system_report.sh | bash
```

### Save and run locally

```bash
# Download the script
curl -O https://garfieldwtf.github.io/myscripts/system_report.sh

# Make it executable
chmod +x system_report.sh

# Run it
./system_report.sh
```

> **✨ Pro Tip:** Bookmark this page or save the command as an alias:
> ```bash
> alias sysinfo='curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash'
> ```

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 💾 Storage & Disks
- Physical disk inventory
- Partition tables with mount points
- Real-time usage statistics
- Smart filtering (excludes virtual filesystems)

</td>
<td width="50%">

### 🧠 Memory Management
- Total RAM & available memory
- Usage percentage with color alerts
- Swap space monitoring
- Memory pressure indicators

</td>
</tr>
<tr>
<td width="50%">

### 🔧 CPU Intelligence
- Processor model & architecture
- Core/thread count
- Real-time usage percentage
- Frequency scaling info

</td>
<td width="50%">

### 📊 Performance Metrics
- Load average (1,5,15 min)
- Top memory-consuming processes
- System uptime & user sessions
- Historical trend data

</td>
</tr>
</table>

---

## 🎨 Screenshots

### Main Report Output
```
╔════════════════════════════════════════════════════════════════════════════╗
║                         SYSTEM INFORMATION REPORT                         ║
╚════════════════════════════════════════════════════════════════════════════╝

Generated on: 2026-04-29 14:30:22
Hostname: my-production-server
================================================================================

=== DISK, PARTITIONS & MOUNTPOINTS ===
Total Physical Disks: 2
Disk List:
  • sda 238.5G
  • sdb 931.5G

Partitions and Mount Points:
FILESYSTEM                      SIZE       USED        AVAIL     USE%    MOUNTPOINT
----------------------------------------------------------------------------------------
/dev/sda1                       100G       45G         55G       45%     /
/dev/sdb1                       900G       300G        600G      33%     /data

=== MEMORY & SWAP UTILIZATION ===
RAM Information:
  • Total Memory: 15.6Gi
  • Used Memory: 8.2Gi
  • Free Memory: 7.4Gi
  • Available Memory: 9.1Gi
  • Usage Percentage: 52%

=== CPU INFORMATION ===
CPU Details:
  • CPU Model: Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz
  • Total Cores: 12
  • Threads per Core: 2
  • CPU Frequency: 2600.000 MHz

=== SYSTEM LOAD & CPU USAGE ===
Load Average (1, 5, 15 min): 2.50, 2.30, 2.10
CPU Usage: 25%

Top 5 Memory-Consuming Processes:
  • chrome            15.2% MEM - /opt/google/chrome/chrome
  • docker            12.1% MEM - /usr/bin/dockerd
  • mysql             8.5% MEM  - /usr/sbin/mysqld
```

### Color Legend

| Color | Meaning | Range |
|-------|---------|-------|
| 🟢 **Green** | Normal/Healthy | 0-74% usage |
| 🟡 **Yellow** | Warning | 75-89% usage |
| 🔴 **Red** | Critical | 90-100% usage |

---

## 📖 Usage Examples

### Basic Usage
```bash
# Just run it
./system_report.sh

# Or via bash
bash system_report.sh
```

### Save Output
```bash
# Save to file
./system_report.sh > system_report.txt

# With timestamp
./system_report.sh > system_report_$(date +%Y%m%d_%H%M%S).txt

# Append to log file
./system_report.sh >> system_history.log
```

### Remote Monitoring
```bash
# Run on remote server via SSH
ssh user@server 'curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash'

# Save remote report locally
ssh user@server 'curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash' > remote_report.txt
```

### Scheduled Reports
```bash
# Add to crontab for daily reports at 9 AM
0 9 * * * /path/to/system_report.sh > /var/log/system_report_$(date +\%Y\%m\%d).txt

# Weekly summary every Monday
0 9 * * 1 curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash | mail -s "Weekly System Report" admin@example.com
```

---

## 💻 System Requirements

### Minimum Requirements
- **OS**: Linux (any distribution) or WSL
- **Bash**: Version 4.0 or higher
- **Permissions**: User-level (no root required)

### Required Utilities
The script uses standard Linux tools that come pre-installed on most distributions:

| Utility | Purpose | Typical Package |
|---------|---------|----------------|
| `df` | Disk information | coreutils |
| `free` | Memory info | procps |
| `lscpu` | CPU details | util-linux |
| `top` | Process monitoring | procps |
| `ps` | Process list | procps |
| `grep` | Text filtering | grep |
| `awk` | Text processing | gawk |

### Installation of Missing Utilities
```bash
# Debian/Ubuntu
sudo apt-get install coreutils procps util-linux gawk grep

# RHEL/CentOS/Fedora
sudo yum install coreutils procps-ng util-linux gawk grep

# Arch Linux
sudo pacman -S coreutils procps-ng util-linux gawk grep
```

---

## 📊 Output Breakdown

### 1. Disk & Partition Information
- **Physical Disks**: Lists all physical storage devices
- **Partitions**: Shows mounted filesystems with sizes
- **Usage Warning**: Highlights partitions >80% usage

### 2. Memory Statistics
- **Total Memory**: Physical RAM installed
- **Available Memory**: Usable memory (includes cache/buffers)
- **Swap Usage**: Virtual memory utilization

### 3. CPU Details
- **Model**: Exact processor型号
- **Cores**: Physical and logical cores
- **Frequency**: Current operating frequency

### 4. System Load
- **Load Average**: Running + waiting processes
- **CPU Usage**: Instantaneous utilization
- **Top Processes**: Memory-intensive applications

---

## 🛠️ Customization

### Excluding/Including Filesystems

Edit the script to customize which filesystems to display:

```bash
# Skip snap and loop devices (default)
if [[ "$filesystem" == *"snap"* ]] || [[ "$filesystem" == *"loop"* ]]; then
    continue
fi

# To include them, comment out or remove the lines above
```

### Changing Warning Thresholds

Modify these values to change color thresholds:

```bash
# Memory thresholds (default: 90% critical, 75% warning)
if [ $mem_usage_percent -ge 90 ]; then    # Change 90 to custom value
    mem_color=$RED
elif [ $mem_usage_percent -ge 75 ]; then  # Change 75 to custom value
    mem_color=$YELLOW
fi

# CPU thresholds (default: 80% critical, 50% warning)
if [ $cpu_usage -ge 80 ]; then
    cpu_color=$RED
elif [ $cpu_usage -ge 50 ]; then
    cpu_color=$YELLOW
fi
```

### Adding Custom Sections

You can easily extend the script:

```bash
# Add network information
print_header "NETWORK INFORMATION"
echo -e "${YELLOW}Network Interfaces:${NC}"
ip -br addr show

# Add temperature monitoring (requires lm-sensors)
if command -v sensors &> /dev/null; then
    print_header "TEMPERATURE INFORMATION"
    sensors
fi
```

### Disabling Colors

```bash
# Colors auto-disable on pipe/redirect, or force disable:
./system_report.sh 2>&1 | cat

# Or modify the script to check for --no-color flag
if [[ "$1" == "--no-color" ]]; then
    export TERM=dumb
fi
```

---

## 🔧 Troubleshooting

### Common Issues & Solutions

<details>
<summary><b>❌ "curl: command not found"</b></summary>

```bash
# Install curl
sudo apt-get install curl        # Debian/Ubuntu
sudo yum install curl            # RHEL/CentOS
sudo pacman -S curl              # Arch
```
</details>

<details>
<summary><b>❌ "bash: line X: syntax error"</b></summary>

This usually means you're using an older bash version. Update bash:
```bash
# Check version
bash --version

# Update bash
sudo apt-get install bash        # Debian/Ubuntu
```
</details>

<details>
<summary><b>❌ "Permission denied" when running script</b></summary>

```bash
# Make script executable
chmod +x system_report.sh

# Or run with bash explicitly
bash system_report.sh
```
</details>

<details>
<summary><b>❌ Weird characters/colors in output</b></summary>

The script uses ANSI color codes. If your terminal doesn't support them:
```bash
# Disable colors by piping to cat
./system_report.sh | cat

# Or redirect to file
./system_report.sh > output.txt
```
</details>

<details>
<summary><b>❌ "WSL: Some disk info missing"</b></summary>

WSL has limited access to hardware information. This is normal - the script will show what's available.
</details>

---

## 🔒 Security

### ✅ This script is SAFE because:

- **Read-only operations**: Only reads system information, never modifies anything
- **No external connections**: Doesn't send data anywhere
- **No root required**: Runs with regular user permissions
- **Open source**: You can review every line of code
- **No dependencies**: Uses only built-in Linux utilities

### 🔐 For paranoid sysadmins

```bash
# Review the script before running
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | less

# Download and audit
wget https://garfieldwtf.github.io/myscripts/system_report.sh
cat system_report.sh | grep -E '(curl|wget|nc|telnet|ssh)'  # Check for network calls
```

---

## 🤝 Contributing

We love contributions! Here's how you can help:

1. 🍴 **Fork the repository**
2. 🔧 **Create your feature branch** (`git checkout -b feature/AmazingFeature`)
3. 💾 **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. 📤 **Push to the branch** (`git push origin feature/AmazingFeature`)
5. 🎉 **Open a Pull Request**

### Ideas for Contributions

- Add GPU information (nvidia-smi, radeontop)
- Include network statistics (bandwidth, connections)
- Add docker container monitoring
- Create JSON/XML output format option
- Add email report functionality

---

## 📝 License

Distributed under the **MIT License**. See `LICENSE` file for more information.

```
MIT License

Copyright (c) 2026 garfieldwtf

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

---

## 🙏 Acknowledgments

- Inspired by classic Linux system monitoring tools
- Built with love for the open-source community
- Special thanks to all contributors and users

---

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/garfieldwtf/myscripts/issues)
- **Script Page**: [garfieldwtf.github.io/myscripts](https://garfieldwtf.github.io/myscripts)

---

<div align="center">

**⭐ If this script saved you time, give it a star on GitHub! ⭐**

---

**Made with ❤️ by garfieldwtf**

[⬆ Back to Top](#-system-information-report-script)

</div>
