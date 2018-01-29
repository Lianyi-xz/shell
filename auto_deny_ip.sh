#!/bin/bash
# auto drop ssh failed ip address

#定义变量
SEC_FILE=/var/log/secure

#截取登陆22端口的恶意 ip
#([0-9]{1,3}\.){3}[0-9]{1,3}匹配ip地址
IP_ADDR=`tail -n 1000 $SEC_FILE |grep "Failed password"|egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}"| sort -nr|uniq -c |awk '$1>=4 {print $2}'`

#开启firewalld服务  systemctl start firewalld
#打开22端口          firewall-cmd --zone=public --add-port=22/tcp --permanent
for i in `echo $IP_ADDR`
do
  #查看该ip是否已经被禁止登陆
  count=`firewall-cmd --list-rich-rules |grep $i |wc -l`
  if [ $count -eq 0 ];then
    firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$i/24' service name='ssh' reject"
    firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$i/24' port port=22 protocol=tcp reject"
    echo "reject $i access"
  else
    echo "$1 is exist"
  fi
done