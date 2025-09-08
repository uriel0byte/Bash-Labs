#! /bin/bash
echo

#ASCII Text

#Basic Info
echo "=====System Info====="

echo -n "Host Name : " ; hostname
echo -n "Kernel Version : " ; uname -r
echo -n "OS : " ; cat /etc/os-release | cut -d '"' -f2 | head -1
#echo -n "Packages : " ; 
echo -n "Shell : " ; which $SHELL
echo -n "CPU : " ; cat /proc/cpuinfo | grep "model name" | cut -d ':' -f2 | head -1
echo -n "GPU : " ; lspci | grep VGA | cut -d ':' -f3

echo

#Uptime Date Load Average
echo "======Date Uptime Loadaverage======"

echo -n "Date : " ; date
echo -n "Uptime : " ; uptime -p
echo -n "Since : " ; uptime -s
echo -n "Load Average : " ; cat  /proc/loadavg

echo

#Who is logged in
echo "=====Users======"

echo "User : $(whoami) --> $(grep "$(whoami)" /etc/passwd)"
echo "All users : " ; w | tail -n +2

echo

#Total CPU usage
echo "=====CPU Usage====="

#echo -n "Cpu usage :" ; top -bn1 | grep "Cpu(s)" | cut -d ',' -f4 | cut -d ' ' -f2

CPU=$(top -bn1 | grep "%Cpu(s):" | cut -d ',' -f4 | cut -d ' ' -f2 | cut -d '.' -f1)
echo "CPU Usage : $((100-$CPU))%"

echo

#Total memory usage (Free vs Used including percentage)
echo "=====Memory Usage====="

echo "Total : "
echo "Used : "
echo "Free : "

echo

#Total disk usage (Free vs Used including percentage)
echo "=====Disk Usage====="

echo "Total : "
echo "Used : "
echo "Free : "

echo

#Top 5 processes by CPU usage
echo "=====TOP 5 Processes by CPU usage=====" ;
ps aux --sort=-%cpu | head -6 | nl

echo

#Top 5 processes by memory usage
echo "=====TOP 5 Processes by Memory usage=====" ;
ps aux --sort=-%mem | head -6 | nl
