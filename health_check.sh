#!/bin/bash

# Prompt for the hostname
read -p "Enter the hostname/IP of the server to inspect: " hostname

# Check if the hostname is empty
if [ -z "$hostname" ]; then
  echo "No hostname provided. Exiting."
  exit 1
fi

# Execute the health check on the remote server
ssh "$hostname" << 'EOF'

# Define colors
header_color="\033[1;34m"
ok_color="\033[32m"
warning_color="\033[33m"
critical_color="\033[31m"
default_color="\033[0m"

# System Information
echo -e "${header_color}System Information"
echo -e "==================${default_color}"
echo "Hostname: $(hostname)"
echo "FQDN: $(hostname -f)"
echo "IPv4 Address: $(hostname -I | awk '{print $1}')"
echo "Operating System: $(uname -s)"
echo "Distribution: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f2)"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""

# CPU Usage
echo -e "${header_color}CPU Usage"
echo -e "=========${default_color}"
cpu_model=$(lscpu | grep 'Model name' | awk -F ':' '{ print $2 }' | sed 's/^ *//g' | sed 's/ *$//g')
cpu_cores=$(lscpu | grep '^CPU(s):' | awk -F ':' '{ print $2 }' | sed 's/^ *//g' | sed 's/ *$//g')
cpu_usage=$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1}')
load_avg=$(uptime | awk -F 'load average: ' '{ print $2 }' | awk -F ', ' '{ print $1, $2, $3 }')
load_avg_1=$(echo $load_avg | awk '{print $1}')
load_avg_5=$(echo $load_avg | awk '{print $2}')
load_avg_15=$(echo $load_avg | awk '{print $3}')
echo "CPU Model: $cpu_model"
echo "CPU Cores: $cpu_cores"
echo "Current CPU Usage: ${cpu_usage}%"
echo "Load Average (1/5/15 minutes): $load_avg"
echo ""

# Memory Usage
echo -e "${header_color}Memory Usage" 
echo -e "============${default_color}" 
memory_usage=$(free | grep Mem | awk '{print ($2 - $4) / $2 * 100.0}')
free -h
echo ""

# Top 5 CPU Consuming Processes
echo -e "${header_color}Top 5 CPU Consuming Processes"
echo -e "=============================${default_color}"
ps -eo user:30,pid,cmd:100,%cpu,%mem,time,start --sort=-%cpu | head -n 6
echo ""

# Top 5 Memory Consuming Processes
echo -e "${header_color}Top 5 Memory Consuming Processes"
echo -e "================================${default_color}"
ps -eo user:30,pid,cmd:100,%cpu,%mem,time,start --sort=-%mem | head -n 6
echo ""

# Disk Usage & Filesystems above 90%
echo -e "${header_color}Disk Usage"
echo -e "==========${default_color}"
df -h | grep '^/dev/'
critical_filesystems=$(df -h | awk '$5+0 > 90 {print $1 " (" $5 ")"}')
echo ""

# Summary of Resource Status
echo -e "${header_color}Health Check Summary of $(hostname)"
echo -e "======================================${default_color}"

# Determine CPU status
if (( $(echo "$cpu_usage > 90" | bc -l) )); then
    cpu_status="Critical"
    cpu_color="${critical_color}"
elif (( $(echo "$cpu_usage > 80" | bc -l) )); then
    cpu_status="Warning"
    cpu_color="${warning_color}"
else
    cpu_status="OK"
    cpu_color="${ok_color}"
fi

# Determine Memory status
if (( $(echo "$memory_usage > 99" | bc -l) )); then
    memory_status="Critical"
    memory_color="${critical_color}"
elif (( $(echo "$memory_usage > 95" | bc -l) )); then
    memory_status="Warning"
    memory_color="${warning_color}"
else
    memory_status="OK"
    memory_color="${ok_color}"
fi

# Determine Load Average statuses
if (( $(echo "$load_avg_1 / $cpu_cores > 1" | bc -l) )); then
    load_avg_1_status="Critical"
    load_avg_1_color="${critical_color}"
else
    load_avg_1_status="OK"
    load_avg_1_color="${ok_color}"
fi

if (( $(echo "$load_avg_5 / $cpu_cores > 1" | bc -l) )); then
    load_avg_5_status="Critical"
    load_avg_5_color="${critical_color}"
else
    load_avg_5_status="OK"
    load_avg_5_color="${ok_color}"
fi

# Print statuses
echo -e "CPU Usage: ${cpu_color}${cpu_status}${default_color} (${cpu_usage}%)" 
echo -e "Memory Usage: ${memory_color}${memory_status}${default_color} (${memory_usage}%)"
echo -e "1 Minute Load Average: ${load_avg_1_color}${load_avg_1_status}${default_color} (${load_avg_1})"
echo -e "5 Minute Load Average: ${load_avg_5_color}${load_avg_5_status}${default_color} (${load_avg_5})"

# Print Filesystem Status
if [ -n "$critical_filesystems" ]; then
    echo -e "Filesystems Over 90% Usage:"
    echo "$critical_filesystems"
else
    echo -e "Filesystems Over 90% Usage: ${ok_color}NULL${default_color}"
fi
EOF
