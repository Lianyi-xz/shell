#!/bin/bash
if [ -n "$1" ] &&  date -d "$1" &>/dev/null  && [ -n "$2" ] &&  date -d "$2" &>/dev/null ;then
  echo $1" "$2
elif [ ! -n "$1" ] && [ ! -n "$2" ];then
  echo "old"
else
  echo "There is no complete start and end time，The shell is about to exit..."
  exit 0
fi