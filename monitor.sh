#!/bin/bash

# Colors 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

check_disk_space() {
    echo -e "${YELLOW}Disk Space Usage:${NC}"
    df -h | awk '$NF=="/" {printf "Root Partition: %s\n", $5}'
    echo "Top 5 directories by size:"
    du -sh /* 2>/dev/null | sort -rh | head -5
    echo ""
}

check_memory_usage() {
    echo -e "${YELLOW}Memory Usage:${NC}"
    free -h | awk '/^Mem:/ {print "Total: " $2 "\tUsed: " $3 "\tFree: " $4}'
    echo "Top 5 processes by memory usage:"
    ps aux --sort=-%mem | awk 'NR<=6 {print $4"%\t"$11}'
    echo ""
}

check_cpu_usage() {
    echo -e "${YELLOW}CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
    echo "Top 5 processes by CPU usage:"
    ps aux --sort=-%cpu | awk 'NR<=6 {print $3"%\t"$11}'
    echo ""
}

check_system_load() {
    echo -e "${YELLOW}System Load:${NC}"
    uptime | awk '{print $10 " " $11 " " $12}'
    echo ""
}

check_network_stats() {
    echo -e "${YELLOW}Network Stats:${NC}"
    netstat -i | awk 'NR>2 {print $1 ": RX packets: " $4 ", TX packets: " $8}'
    echo "Current connections:"
    netstat -ant | awk '{print $6}' | sort | uniq -c | sort -rn
    echo ""
}

check_zombie_processes() {
    echo -e "${YELLOW}Zombie Processes:${NC}"
    zombies=$(ps aux | awk '{if ($8=="Z") {print $2}}' | wc -l)
    echo "Number of zombie processes: $zombies"
    if [ $zombies -gt 0 ]; then
        echo "Zombie process details:"
        ps aux | awk '{if ($8=="Z") {print $0}}'
    fi
    echo ""
}

check_disk_io() {
    echo -e "${YELLOW}Disk I/O:${NC}"
    iostat -x 1 2 | awk '/^[a-z]/ {print $1 ": read " $6 " MB/s, write " $7 " MB/s"}'
    echo ""
}

check_system_updates() {
    echo -e "${YELLOW}System Updates:${NC}"
    if command -v apt-get &> /dev/null; then
        updates=$(apt-get -s upgrade | grep -P '^\d+ upgraded' | cut -d" " -f1)
        echo "$updates packages can be upgraded."
    elif command -v yum &> /dev/null; then
        updates=$(yum check-update --quiet | grep -v "^$" | wc -l)
        echo "$updates packages can be upgraded."
    else
        echo "Unable to check for updates. Package manager not recognized."
    fi
    echo ""
}

check_uptime() {
    echo -e "${YELLOW}System Uptime:${NC}"
    uptime -p
    echo ""
}

check_failed_services() {
    echo -e "${YELLOW}Failed Systemd Services:${NC}"
    systemctl --failed
    echo ""
}

# to run all checks
main() {
    echo -e "${GREEN}==== Server Health Monitor ====${NC}"
    echo "Date: $(date)"
    echo ""
    
    check_disk_space
    check_memory_usage
    check_cpu_usage
    check_system_load
    check_network_stats
    check_zombie_processes
    check_disk_io
    check_system_updates
    check_uptime
    check_failed_services
    
    echo -e "${GREEN}==== End of Health Report ====${NC}"
}


main

#bashsrfile
