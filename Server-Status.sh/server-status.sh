#! /bin/bash
echo

#ASCII Text
echo "   _____                              ____            ____                                              _____ __        __      "
echo "  / ___/___  ______   _____  _____   / __ \___  _____/ __/___  _________ ___  ____ _____  ________     / ___// /_____ _/ /______"
echo "  \__ \/ _ \/ ___/ | / / _ \/ ___/  / /_/ / _ \/ ___/ /_/ __ \/ ___/ __ \`__ \/ __ \`/ __ \/ ___/ _ \    \__ \/ __/ __ \`/ __/ ___/"
echo " ___/ /  __/ /   | |/ /  __/ /     / ____/  __/ /  / __/ /_/ / /  / / / / / / /_/ / / / / /__/  __/   ___/ / /_/ /_/ / /_(__  ) "
echo "/____/\___/_/    |___/\___/_/     /_/    \___/_/  /_/  \____/_/  /_/ /_/ /_/\__,_/_/ /_/\___/\___/   /____/\__/\__,_/\__/____/  "

#Basic Info
echo "====================="
echo "#    System Info    #"
echo "====================="

echo -n "Host Name : " ; hostname
echo -n "Kernel Version : " ; uname -r
# 'cut -d' changes the delimiter to quotes to isolate the OS name, and 'head -1' grabs only the first result.
echo -n "OS : " ; cat /etc/os-release | cut -d '"' -f2 | head -1
#echo -n "Total Packages and Package Manager: " ; 
echo -n "Shell : " ; which $SHELL
# /proc/cpuinfo holds hardware data, and I am using grep to find the specific "model name" line.
echo -n "CPU : " ; cat /proc/cpuinfo | grep "model name" | cut -d ':' -f2 | head -1
# lspci lists all hardware connected to the PCI bus. I filter for "VGA" to find the graphics card.
# The output has colons, so I use cut (-d ':') to split the line at the colons and grab the 3rd piece (-f3), which is the GPU name.
echo -n "GPU : " ; lspci | grep VGA | cut -d ':' -f3

echo

# Network Information
echo "====================="
echo "#   Network Info    #"
echo "====================="
echo -n "IP Addresses : "; hostname -I
# ip route shows the system's routing table. 
# awk searches for the line containing the word "default", and then prints the 3rd column ($3), which is the actual IP address of the gateway.
echo -n "Default Gateway : "; ip route | awk '/default/ {print $3}'

echo

# Open Ports / Listening Services
#echo "==============================="
#echo "#  Open Ports / Listening      #"
#echo "==============================="

#echo

#Uptime Date Load Average
echo "==================================="
echo "#     Date Uptime Loadaverage     #"
echo "==================================="

echo -n "Date : " ; date
echo -n "Uptime : " ; uptime -p
echo -n "Since : " ; uptime -s
echo -n "Load Average : " ; cat  /proc/loadavg

echo

# Last System Update
#echo "====================="
#echo "# Last System Update#"
#echo "====================="

#echo

#Who is logged in
echo "=================================="
echo "#             Users              #"
echo "=================================="

# $() runs a command inside another command. Mention that /etc/passwd is where user account info is stored in Linux.
echo "User : $(whoami) --> $(grep "$(whoami)" /etc/passwd)"
# the 'w' command shows who is logged on and what they are doing., and that 'tail -n +2' is used to skip the first header line of the output.
echo "All users : " ; w | tail -n +2

echo

#Failed Loging Attempts
#echo "=================================="
#echo "#      Failed Login Attempts     #"
#echo "=================================="

#echo

# Failed Services
#echo "====================="
#echo "#  Failed Services   #"
#echo "====================="

#echo

#Total CPU usage
echo "==================="
echo "#    CPU Usage    #"
echo "==================="

# First try
#echo -n "Cpu usage :" ; top -bn1 | grep "Cpu(s)" | cut -d ',' -f4 | cut -d ' ' -f2

# top -bn1 runs the task manager exactly once in batch mode.
# I grep for "%Cpu(s):" to isolate the CPU stats line.
# The multiple 'cut' commands slice the line by commas and spaces to extract the "idle" CPU percentage.
# Finally, I subtract that idle number from 100 to get my active CPU usage percentage.
CPU=$(top -bn1 | grep "%Cpu(s):" | cut -d ',' -f4 | cut -d ' ' -f2 | cut -d '.' -f1)
echo "CPU Usage : $((100-$CPU))%"

echo

#Total memory usage (Free vs Used including percentage) free -h
echo "======================"
echo "#    Memory Usage    #"
echo "======================"

# free -h displays RAM usage in human-readable format (Megabytes/Gigabytes).
# I use awk to target specific columns: $2 is Total RAM, $3 is Used, and $7 is Free/Available.
# Inside the awk command, I also do inline math: ($3/$2)*100 calculates the exact percentage of used RAM.
echo -n "Total : " ; free -h | grep "Mem:" | awk '{print $2}'
echo "Used : $(free -h | grep "Mem:" | awk '{print $3}') ($(free | grep "Mem:" | awk '{printf "%.1f", ($3/$2)*100}')%)"
echo "Free : $(free -h | grep "Mem:" | awk '{print $7}') ($(free | grep "Mem:" | awk '{printf "%.1f", ($7/$2)*100}')%)"

echo

#Total disk usage (Free vs Used including percentage) df -h
echo "===================="
echo "#    Disk Usage    #"
echo "===================="

# df -h shows file system disk space. 
# I use grep "/$" (the $ means "end of line" in regex) so it strictly matches the main root drive and ignores temp drives.
# Like the memory section, awk grabs the total ($2), used ($3), and available ($4) columns, and calculates the percentage.
echo -n "Total : " ; df -h | grep "/$" | awk '{print $2}'
echo -n "Used : " ; df -h | grep "/$" | awk '{print $3 " (" $5 ")"}'
echo "Free : $(df -h | grep "/$" | awk '{print $4}') ($(df -h | grep "/$" | awk '{printf "%.1f", ($4/$2)*100}')%)"

echo

#Top 5 processes by CPU usage
echo "==========================================="
echo "#      TOP 5 Processes by CPU usage       #"
echo "==========================================="

# ps aux lists all currently running processes on the system.
# --sort=-%cpu sorts them by CPU usage. The MINUS sign (-) is critical: it forces a descending sort (highest to lowest).
# head -6 grabs the top 5 processes PLUS the header row so we know what the columns mean.
# awk cleans up the output, printing only the User ($1), PID ($2), CPU% ($3), Start Time ($9), and Command ($11).
ps aux --sort=-%cpu | head -6 | awk '{print $1 "\t" $2 "\t" $3 "\t" $9 "\t" $11}'

echo

#Top 5 processes by memory usage
echo "==========================================="
echo "#     TOP 5 Processes by Memory usage     #"
echo "==========================================="

# This does the exact same thing as above, but sorts by memory usage (--sort=-%mem) 
# and prints the Memory percentage column ($4) instead of the CPU column.
ps aux --sort=-%mem | head -6 | awk '{print $1 "\t" $2 "\t" $4 "\t" $9 "\t" $11}'
