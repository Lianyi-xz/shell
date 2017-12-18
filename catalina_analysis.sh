#!/bin/bash
# Author ZhaoRan
# Create:2017-08-18 Update:2017-08-20
# Email:zrwang@stwitinc.com
# version:3.0
# 用于分析tomcat日志文件
#
#  2017-08-18 08:50:25.772
#
# 防止脚本被重复执行
PIDPATH=/tmp/test.pid
if [ -f "$PIDPATH" ];then
  echo "脚本已启动，或异常关闭。请等待脚本执行完毕或手动终止脚本并清理${PIDPATH}文件"
  exit 0
else
  touch PIDPATH
  echo $$ > $PIDPATH
fi

# 设置日志路径以及读取时间
URL=/soft
FILE=catalina.out
OUTFILE=/soft/end.txt
STIME="2017-08-18 08:57:45.896"
ETIME=`tail -n 200 catalina.out |grep 'Process service servlet request end' |awk 'END{ print $1" "$2}'`
OLDTIME=`awk '/Process service servlet request begin/{print $1" "$2;exit}' $URL/$FILE`
if [ "$STIME" == "" ] || [ `date -d "$STIME" +%s` -lt `date -d "$OLDTIME" +%s` ] ;then
  RSTIME=$OLDTIME
elif [ `date -d "$STIME" +%s` -ge `date -d "$ETIME" +%s` ];then
  exit 0
else
  RSTIME=$STIME
fi
RETIME=$ETIME
sed -i "24c STIME=\"$RETIME\"" $(basename $0)
#echo $RSTIME
#echo $RETIME

# 获取日志中事务执行时间
#function processend() {
sed -n '/'"$RSTIME"'/,/'"$RETIME"'/p' $URL/$FILE  | grep 'Process service servlet request end' |awk '$11 >1000 { print $1" "$2"\t"$3"\t"$11}' >> $OUTFILE
#}

#删除PID文件
rm -f $PIDPATH