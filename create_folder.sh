#!/bin/bash
LOG=/back/server-status/last-log
if [ ! -d $LOG ]
then
  mkdir -p /back/server-status/last-log
fi