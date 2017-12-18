#!/bin/bash
function Stop(){
  echo "判断 $1 进程状态..."
  count=`ps -ef |grep -v "grep"|grep "$1" |wc -l`
  sec=5
  if [ $count -gt 0 ];then
    echo "$1 进程正在运行，准备停止..."
    cd /usr/local/tomcat/$1/bin
    sh catalina.sh stop &> /dev/null
    echo "再判断 $1 进程状态..."
    sleep $sec

    aftercount=`ps -ef |grep -v "grep"|grep "$1" |wc -l`
    if [ $aftercount -gt 0 ];then
      Pid=`ps -ef |grep -v "grep" |grep "$1"|awk '{print $2}'`
      kill -9 $Pid
      echo "$1 进程已停止..."
    elif [ $aftercount -eq 0 ];then
      echo "$1 进程已停止..."
    fi
  elif [ $count -eq 0 ];then
    echo "$1 进程处于停止状态..."
  fi
}

function Start(){
  count1=`ps -ef |grep -v "grep"|grep "node1"|wc -l`
  count2=`ps -ef |grep -v "grep"|grep "node2"|wc -l`
  count=`ps -ef |grep -v "grep"|grep "tomcat"|wc -l`
  if [ $count -lt 2 ];then
    echo ""
    echo "使用以下命令,启动 tomcat 进程..."
    echo ""
  fi
  if [ $count1 -eq 0 ];then
    echo "cd /usr/local/tomcat/node1/bin"
    echo "sh catalina.sh start "
    echo ""
  fi
  if [ $count2 -eq 0 ];then
    echo "cd /usr/local/tomcat/node2/bin"
    echo "sh catalina.sh start "
    echo ""
  fi
}

function Back(){
  echo "检测备份环境状态..."
  if [ ! -d /usr/local/tomcat/$1/webapps/back ];then
    mkdir -p /usr/local/tomcat/$1/webapps/back
  fi
  echo "备份环境准备就绪..."
}

node1=/usr/local/tomcat/node1/webapps
node2=/usr/local/tomcat/node2/webapps
old=/soft
Time=`date +%Y-%m-%d-%H%M`
cd $node1
echo "查找 node1 节点..."
for i in stw-web stw-mgr stw-webpc stw-news
do
  if [ -f "${i}.zip" ];then
    echo "发现需更新程序: ${i} ..."
    Stop "node1";
    echo "备份现有程序: ${i} ..."
    Back "node1";
    cd $node1
    tar cf ./back/${i}-${Time}.tar ${i}
    mv ${i} $old
    echo "更新程序: ${i} ..."
    unzip -q ${i}.zip
    mv "${i}.zip" $old
  fi
done

cd $node2
for i in stw-webpc stw-news stw-web stw-mgr
do
  if [ -f "${i}.zip" ];then
    echo "发现需更新程序: ${i} ..."
    Stop "node2";
    echo "备份现有程序: ${i} ..."
    Back "node2";
    cd $node2
    tar cf ./back/${i}-${Time}.tar ${i}
    mv ${i} $old
    echo "更新程序: ${i} ..."
    unzip -q ${i}.zip
    mv "${i}.zip" $old
  fi
done

echo "清理废弃文件..."
if [ -d $node1/back ];then
  find $node1/back/  -mtime +7 -name "*.tar" -exec rm -rf {} \;
fi
if [ -d $node2/back ];then
  find $node2/back/  -mtime +7 -name "*.tar" -exec rm -rf {} \;
fi
cd $old
rm -rf stw*
Start;