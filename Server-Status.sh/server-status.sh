#! /bin/bash
echo

#ASCII Text

#Basic Info
echo "====================="
echo "#    System Info    #"
echo "====================="

echo -n "Host Name : " ; hostname
echo -n "Kernel Version : " ; uname -r
echo -n "OS : " ; cat /etc/os-release | cut -d '"' -f2 | head -1
#echo -n "Packages : " ; 
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

#Who is logged in
echo "=================================="
echo "#             Users              #"
echo "=================================="

echo "User : $(whoami) --> $(grep "$(whoami)" /etc/passwd)"
echo "All users : " ; w | tail -n +2

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
