#!/bin/bash
DATE=`date +%Y-%m-%d`
DAY=`LC_ALL="C" date +%d/%b/%Y`
for HOUR in {00..23}
do
for MON in {00..59}
do
  echo "${DAY}:${HOUR}:${MON}"
  cat localhost_access_log.${DATE}.txt |grep "${DAY}:${HOUR}:${MON}"|grep -v "HEAD"|awk '{print $9}' |sort|uniq -c
done
done