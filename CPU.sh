#!/bin/bash
DATE=$(date +%F" "%H:%M)
IP=$(ifconfig eth0 |awk -F '[ :]+' '/inet addr/{print $4}')  #只支持centos6
IP=$(ifconfig eno16777736|sed -n '2p'|awk '{print $2}') #支持centos7
IP=$(ifconfig eno16777736 |awk 'NR==2{print $2}')
MAIL="example@mail.com"
if ! which vmstat &>/dev/null;then
    echo "vmstat command no found,please install procps package."
    exit 1
fi
US=$(vmstat|awk 'NR==3{print $13}')
SY=$(vmstat|awk 'NR==3{print $14}')
IDLE=$(vmstat|awk 'NR==3{print $15}')
WAIT=$(vmstat|awk 'NR==3{print $16}')
USE=$(($US+$SY）)
if [ $USE -ge 50 ];then
  echo "
  Date:$DATE
  Host:$IP
  Problem:CPU utilization $USE
  " | mail -s "CPU Monitor" $MAIL
fi