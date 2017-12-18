#!/bin/bash
DATE=$(date +%F" "%H:%M)
IP=$(ifconfig eth0 |awk -F '[ :]+' '/inet addr/{print $4}')  #只支持centos6
IP=$(ifconfig eno16777736|sed -n '2p'|awk '{print $2}') #支持centos7
IP=$(ifconfig eno16777736 |awk 'NR==2{print $2}')
MAIL="example@mail.com"
TOTAL=$(free -m |awk '/Mem/{print $2}')
USE=$(free -m |awk '/Mem/{print $3-$6-$7}')
FREE=$(($TOTAL-$USE))
if [ $FREE -lt 1024 ];then
  echo "
  Date:$DATE
  Host:$IP
  Problem:Mem  Total=$Total,Use=$USE,Free=$FREE
  " | mail -s "Memory Monitor" $MAIL
fi