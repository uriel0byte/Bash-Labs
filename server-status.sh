#! /bin/bash

#ASCII Text

#Basic Info
echo -n "Host Name : " ; hostname
echo -n "Kernel Version : " ; uname -r
echo -n "OS : " ; cat /etc/os-release | cut -d '"' -f2 | head -1
echo -n "Packages : " ; 
echo -n "Shell : " ; which $SHELL
echo -n "CPU Spec : " ; cat /proc/cpuinfo | grep "model name" | cut -d ':' -f2 | head -1
echo -n "GPU : " ; lspci | grep VGA | cut -d: -f3

#Uptime Date
echo -n "Date : " ; date
echo -n "Uptime : " ; uptime -p
echo -n "Since : " ; uptime -s

#Who is logged in
echo "User : $(whoami) --> $(grep "$(whoami)" /etc/passwd)"
echo -n "All users : " ; w | tail -n +2

#Load Average
echo -n "Load Average : " ; cat  /proc/loadavg

#Total CPU usage
echo -n "Cpu usage :" ; top -bn1 | grep "Cpu(s)"

#Total memory usage (Free vs Used including percentage)
echo -n "Mem usage(Free) : "
echo -n "Mem usage(Used) : "

#Total disk usage (Free vs Used including percentage)
echo -n "Disk usage(Free): "
echo -n "Disk usage(Used) : "
#Top 5 processes by CPU usage
echo -n "===TOP 5 Processes by CPU usage===" ;
ps aux --sort=-%cpu | head -5 | nl
#Top 5 processes by memory usage
echo -n "===TOP 5 Processes by Mem usage===" ;
ps aux --sort=-%mem | head -5 | nl
