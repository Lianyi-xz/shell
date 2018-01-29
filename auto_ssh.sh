#!/bin/bash
#先配置免密钥登陆
#将远程主机的ip写入同目录的ip.txt中

if [ ! -f ip.txt ]; then
    echo "Please create ip.txt"
fi

if [ -z "$*" ]; then
    echo "Usage: $0 command,Example{rm /tmp/test.txt}"
    exit
fi

  count=`cat ip.txt |wc -l`
  rm -rf ip.txt.swp
  i=0
while ((1<$count))
do
  i=`expr $i+1`
  sed "${i}s/^/&${i} /g" ip.txt >> ip.txt.swp
  IP=`awk -v I="$i" '{if(I==$1)print $2}' ip.txt.swp`

  ssh -q -l root $IP "$*;echo -e '------------------------------\nThe $IP Exec Command: $* success !\n\n';sleep 2"

done