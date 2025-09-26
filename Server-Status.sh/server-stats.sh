#! /bin/bash
echo

#ASCII Text
echo "   _____                              ____            ____                                              _____ __        __      "
echo "  / ___/___  ______   _____  _____   / __ \___  _____/ __/___  _________ ___  ____ _____  ________     / ___// /_____ _/ /______"
echo "  \__ \/ _ \/ ___/ | / / _ \/ ___/  / /_/ / _ \/ ___/ /_/ __ \/ ___/ __ \`__ \/ __ \`/ __ \/ ___/ _ \    \__ \/ __/ __ \`/ __/ ___/"
echo " ___/ /  __/ /   | |/ /  __/ /     / ____/  __/ /  / __/ /_/ / /  / / / / / / /_/ / / / / /__/  __/   ___/ / /_/ /_/ / /_(__  ) "
echo "/____/\___/_/    |___/\___/_/     /_/    \___/_/  /_/  \____/_/  /_/ /_/ /_/\__,_/_/ /_/\___/\___/   /____/\__/\__,_/\__/____/  "

echo

#Basic Info
echo "====================="
echo "#    System Info    #"
echo "====================="

echo -n "Host Name : " ; hostname
echo -n "Kernel Version : " ; uname -r
echo -n "OS : " ; cat /etc/os-release | cut -d '"' -f2 | head -1
if command -v apt &> /dev/null; then
    PKG_COUNT=$(apt list --installed 2>/dev/null | grep -c '^')
    echo "Packages : $PKG_COUNT (Package Manager: apt)"
elif command -v dnf &> /dev/null; then
    PKG_COUNT=$(dnf list installed 2>/dev/null | grep -c '^[a-zA-Z0-9]')
    echo "Packages : $PKG_COUNT (Package Manager: dnf)"
elif command -v yum &> /dev/null; then
    PKG_COUNT=$(yum list installed 2>/dev/null | grep -c '^[a-zA-Z0-9]')
    echo "Packages : $PKG_COUNT (Package Manager: yum)"
elif command -v pacman &> /dev/null; then
    PKG_COUNT=$(pacman -Qq 2>/dev/null | wc -l)
    echo "Packages : $PKG_COUNT (Package Manager: pacman)"
elif command -v zypper &> /dev/null; then
    PKG_COUNT=$(zypper se --installed-only 2>/dev/null | grep -c '^i |')
    echo "Packages : $PKG_COUNT (Package Manager: zypper)"
elif command -v apk &> /dev/null; then
    PKG_COUNT=$(apk info 2>/dev/null | wc -l)
    echo "Packages : $PKG_COUNT (Package Manager: apk)"
else
    echo "Packages : Unknown (Package Manager: Unknown)"
fi

echo -n "Shell : " ; which $SHELL
echo -n "CPU : " ; cat /proc/cpuinfo | grep "model name" | cut -d ':' -f2 | head -1
echo -n "GPU : " ; lspci | grep VGA | cut -d ':' -f3

echo

#Uptime Date Load Average
echo "==================================="
echo "#     Date Uptime Loadaverage     #"
echo "==================================="

echo -n "Date : " ; date
echo -n "Uptime : " ; uptime -p
echo -n "Since : " ; uptime -s
echo -n "Load Average : " ; cat  /proc/loadavg

echo

# Network Information by AI
echo "====================="
echo "#  Network Info     #"
echo "====================="
echo -n "IP Addresses : "; hostname -I
echo -n "Default Gateway : "; ip route | awk '/default/ {print $3}'
echo -n "Active Interfaces : "; ip -o link show | awk -F': ' '{print $2}' | grep -v lo | tr '\n' ' '; echo

echo

# Open Ports / Listening Services by AI
echo "==============================="
echo "#  Open Ports / Listening      #"
echo "==============================="
if command -v ss &> /dev/null; then
    ss -tulpn
elif command -v netstat &> /dev/null; then
    netstat -tulpn
else
    echo "No suitable tool found for open ports."
fi

echo

# Last System Update by AI
echo "====================="
echo "# Last System Updat #"
echo "====================="
if [ -f /var/log/apt/history.log ]; then
    echo -n "Last apt update: "; grep -i start-date /var/log/apt/history.log | tail -1 | cut -d' ' -f2-
elif [ -f /var/log/dnf.rpm.log ]; then
    echo -n "Last dnf update: "; grep -i upgraded /var/log/dnf.rpm.log | tail -1 | cut -d' ' -f1-2
elif [ -f /var/log/pacman.log ]; then
    echo -n "Last pacman update: "; grep -i upgraded /var/log/pacman.log | tail -1 | cut -d' ' -f1-2
else
    echo "No update log found."
fi

echo

# Failed Services by AI
echo "====================="
echo "#  Failed Services   #"
echo "====================="
if command -v systemctl &> /dev/null; then
    systemctl --failed
else
    echo "systemctl not available."
fi

echo

#Who is logged in
echo "=================================="
echo "#             Users              #"
echo "=================================="

echo "User : $(whoami) --> $(grep "$(whoami)" /etc/passwd)"
echo "All users : " ; w | tail -n +2

echo

# Recent authentication events
echo "==================================="
echo "#      Recent Auth Log Events     #"
echo "==================================="
if [ -f /var/log/auth.log ]; then
    echo "Recent Auth Events:"
    tail /var/log/auth.log
elif [ -f /var/log/secure ]; then
    echo "Recent Auth Events:"
    tail /var/log/secure
else
    echo "No authentication log file found."
fi

echo

#Total CPU usage
echo "==================="
echo "#    CPU Usage    #"
echo "==================="

#echo -n "Cpu usage :" ; top -bn1 | grep "Cpu(s)" | cut -d ',' -f4 | cut -d ' ' -f2

CPU=$(top -bn1 | grep "%Cpu(s):" | cut -d ',' -f4 | cut -d ' ' -f2 | cut -d '.' -f1)
echo "CPU Usage : $((100-$CPU))%"

echo

#Total memory usage (Free vs Used including percentage) free -h
echo "======================"
echo "#    Memory Usage    #"
echo "======================"

echo -n "Total : " ; free -h | grep "Mem:" | awk '{print $2}'
echo "Used : $(free -h | grep "Mem:" | awk '{print $3}') ($(free | grep "Mem:" | awk '{printf "%.1f", ($3/$2)*100}')%)"
echo "Free : $(free -h | grep "Mem:" | awk '{print $7}') ($(free | grep "Mem:" | awk '{printf "%.1f", ($7/$2)*100}')%)"

echo

#Total disk usage (Free vs Used including percentage) df -h
echo "===================="
echo "#    Disk Usage    #"
echo "===================="

echo -n "Total : " ; df -h | grep "/$" | awk '{print $2}'
echo -n "Used : " ; df -h | grep "/$" | awk '{print $3 " (" $5 ")"}'
echo "Free : $(df -h | grep "/$" | awk '{print $4}') ($(df -h | grep "/$" | awk '{printf "%.1f", ($4/$2)*100}')%)"

echo

#Top 5 processes by CPU usage
echo "==========================================="
echo "#      TOP 5 Processes by CPU usage       #"
echo "==========================================="
ps aux --sort=-%cpu | head -6 | awk '{print $1 "\t" $2 "\t" $3 "\t" $9 "\t" $11}'

echo

#Top 5 processes by memory usage
echo "==========================================="
echo "#     TOP 5 Processes by Memory usage     #"
echo "==========================================="
ps aux --sort=-%mem | head -6 | awk '{print $1 "\t" $2 "\t" $4 "\t" $9 "\t" $11}'
