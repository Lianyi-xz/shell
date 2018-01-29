#!/bin/bash
#先配置免密钥登陆
#将需同步主机的ip写入同目录的ip.txt中
#传入两个参数： 本地文件/目录  远端目录

if [ ! -f ip.txt ]; then
    echo "Please create ip.txt"
fi

if [ -z "$1" ]; then
    echo "Usage: $0 command,Example{Src_Files|Src_Dir Des_dir}"
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
scp -r $1 root@${IP}:$2
done