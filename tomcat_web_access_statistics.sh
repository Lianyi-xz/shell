#!/bin/bash
DATE=`date +%Y-%m-%d`
DAY=`LC_ALL="C" date +%d/%b/%Y`
for HOUR in {00..23}
do
for MON in {00..59}
do
  DATA=`cat localhost_access_log.${DATE}.txt |grep "${DAY}:${HOUR}:${MON}"|awk '{print $10}'|grep -v "-" |awk '{a+=$0}END{print a+=0}'`
  echo "${DAY}:${HOUR}:${MON}    ${DATA}"
done
done