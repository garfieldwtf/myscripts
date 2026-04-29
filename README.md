# System Information Report Script

A comprehensive bash script that collects and displays detailed system information including memory usage, CPU details, disk partitions, and system load. Works on Linux systems including WSL (Windows Subsystem for Linux).

## Features

- 💾 **Disk & Storage Information**
  - Number of physical disks
  - Partition details with mount points
  - Disk usage with size information
  - Filters out virtual filesystems (tmpfs, snap, loop devices)

- 🧠 **Memory Statistics**
  - Total RAM and available memory
  - Current RAM utilization percentage
  - Swap space information (if configured)

- 🔧 **CPU Details**
  - CPU model and vendor
  - Number of cores and threads
  - CPU frequency
  - Real-time CPU usage percentage

- 📊 **System Load**
  - Load average (1, 5, 15 minutes)
  - System uptime
  - Current user sessions

- 📈 **Additional Features**
  - Top 5 memory-consuming processes
  - Color-coded output for better readability
  - Clean, formatted table layouts

## Quick Install & Run

### One-liner (No installation required)
```bash
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash
```

### With wget (alternative)
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

## Usage Examples

### Basic usage
```bash
bash system_report.sh
```

### Save output to a file
```bash
bash system_report.sh > system_report.txt
```

### Save output with timestamp
```bash
bash system_report.sh > system_report_$(date +%Y%m%d_%H%M%S).txt
```

### Pipe to less for easy scrolling
```bash
bash system_report.sh | less -R
```

## Sample Output

```
╔════════════════════════════════════════════════════════════════════════════╗
║                         SYSTEM INFORMATION REPORT                         ║
╚════════════════════════════════════════════════════════════════════════════╝

Generated on: 2026-04-29 14:30:22
Hostname: my-server
================================================================================

=== DISK, PARTITIONS & MOUNTPOINTS ===
Total Physical Disks: 2
Disk List:
  • sda 238.5G
  • sdb 931.5G

Partitions and Mount Points:
FILESYSTEM                      SIZE       USED            AVAIL           USE%     MOUNTPOINT
--------------------------------------------------------------------------------------------------------
/dev/sda1                       100G       45G             55G             45%      /
/dev/sdb1                       900G       300G            600G            33%      /data

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

System Uptime and Users:
  • 14:30:22 up 5 days, 3:22, 3 users, load average: 2.50, 2.30, 2.10

Top 5 Memory-Consuming Processes:
  • chrome            15.2% MEM - /opt/google/chrome/chrome
  • docker            12.1% MEM - /usr/bin/dockerd
  • mysql             8.5% MEM  - /usr/sbin/mysqld
```

## Requirements

- Bash 4.0 or higher
- Standard Linux utilities: `df`, `free`, `lscpu`, `top`, `ps`, `grep`, `awk`
- No root privileges required (runs with regular user permissions)

## Supported Systems

- ✅ Ubuntu/Debian
- ✅ CentOS/RHEL/Fedora
- ✅ WSL (Windows Subsystem for Linux)
- ✅ Most Linux distributions

## Color Coding

The script uses color coding to highlight critical information:

- 🟢 **Green**: Normal/healthy values (< 75% usage)
- 🟡 **Yellow**: Warning level (75-89% usage)
- 🔴 **Red**: Critical level (≥ 90% usage)

## Customization

### Include snap and loop devices
Edit the script and comment out these lines:
```bash
# Skip snap and loop devices to reduce clutter
if [[ "$filesystem" == *"snap"* ]] || [[ "$filesystem" == *"loop"* ]]; then
    continue
fi
```

### Change threshold values
Modify these lines to change color thresholds:
```bash
if [ $mem_usage_percent -ge 90 ]; then    # Change 90 to desired value
    mem_color=$RED
elif [ $mem_usage_percent -ge 75 ]; then  # Change 75 to desired value
    mem_color=$YELLOW
```

### Disable colors
Colors are automatically disabled when output is redirected or piped. To force disable:
```bash
bash system_report.sh --no-color
```

## Troubleshooting

### "command not found" errors
Ensure the required utilities are installed:
```bash
# Ubuntu/Debian
sudo apt-get install procps util-linux

# CentOS/RHEL
sudo yum install procps-ng util-linux
```

### Script doesn't execute
Make sure the script has execute permissions:
```bash
chmod +x system_report.sh
```

### WSL specific issues
The script is optimized for WSL and handles:
- Virtual filesystems
- Windows drive mounting (C:, D:, etc.)
- Docker Desktop integration

## Security Notes

- The script only reads system information - it does not modify anything
- No sensitive data is collected or transmitted
- All processing is done locally on your machine

## License

MIT License - Feel free to use, modify, and distribute.

## Author

Created by garfieldwtf

## Version History

- **v1.0** - Initial release
  - Basic system information collection
  - Color-coded output
  - WSL compatibility

## Contributing

Found a bug or have a suggestion? Feel free to:
1. Open an issue on GitHub
2. Submit a pull request
3. Contact the author

## Support

For issues specific to running the script from:
```bash
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash
```

Ensure you have `curl` installed:
```bash
# Ubuntu/Debian
sudo apt-get install curl

# CentOS/RHEL
sudo yum install curl
```

## Related Scripts

Check out other useful scripts at [garfieldwtf.github.io/myscripts](https://garfieldwtf.github.io/myscripts)
```

This README provides:

1. **Clear installation instructions** including the curl one-liner you requested
2. **Usage examples** for different scenarios
3. **Sample output** so users know what to expect
4. **Troubleshooting** section for common issues
5. **Customization options** for advanced users
6. **Security notes** to assure users it's safe
7. **Support information** for your specific hosting method

Save this as `README.md` in your repository, and when users run:
```bash
curl -s https://garfieldwtf.github.io/myscripts/system_report.sh | bash
