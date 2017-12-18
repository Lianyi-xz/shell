#!/bin/bash
LOG=/usr/local/tomcat/logs
LOG2=/usr/local/tomcat/node1/logs
LOG_BAK=/back/log
NODE1=$LOG_BAK/node1
NODE2=$LOG_BAK/node2
CATALINA_FILE=/usr/local/tomcat/logs/catalina.out
CATALINA_FILE2=/usr/local/tomcat/node1/logs/catalina.out
if [ ! -d $NODE1 ]
 then
  mkdir -p /back/log/node1
fi

if [ ! -d $NODE2 ]
 then
  mkdir -p /back/log/node2
fi
cp $CATALINA_FILE $NODE1/catalina.out-$(date +%Y-%m-%d).log
echo $(date +%Y-%m-%d) ":node1 log split success">>/back/log/split.log
echo "">$CATALINA_FILE

cp $CATALINA_FILE2 $NODE2/catalina.out-$(date +%Y-%m-%d).log
echo $(date +%Y-%m-%d) ":node2 log split success">>/back/log/split.log
echo "">$CATALINA_FILE2

cd $LOG
find $LOG -mtime +10 -name "catalina.*.log" -exec rm -rf {} \;
find $LOG -mtime +10 -name "host-manager.*.log" -exec rm -rf {} \;
find $LOG -mtime +10 -name "localhost.*.log" -exec rm -rf {} \;
find $LOG -mtime +10 -name "localhost_access_log.*.txt" -exec rm -rf {} \;
find $LOG -mtime +10 -name "manager.*.log" -exec rm -rf {} \;
echo $(date +%Y-%m-%d) ":node1 log move success">>/back/log/split.log

cd $LOG2
find $LOG2 -mtime +10 -name "catalina.*.log" -exec rm -rf {} \;
find $LOG2 -mtime +10 -name "host-manager.*.log" -exec rm -rf {} \;
find $LOG2 -mtime +10 -name "localhost.*.log" -exec rm -rf {} \;
find $LOG2 -mtime +10 -name "localhost_access_log.*.txt" -exec rm -rf {} \;
find $LOG2 -mtime +10 -name "manager.*.log" -exec rm -rf {} \;
echo $(date +%Y-%m-%d) ":node2 log move success">>/back/log/split.log

cd $NODE1
find $NODE1 -mtime +10 -name "catalina.*.log" -exec rm -rf {} \;
echo $(date +%Y-%m-%d) ":node1bak log del success">>/back/log/split.log

cd $NODE2
find $NODE2 -mtime +10 -name "catalina.*.log" -exec rm -rf {} \;
echo $(date +%Y-%m-%d) ":node2bak log del success">>/back/log/split.log