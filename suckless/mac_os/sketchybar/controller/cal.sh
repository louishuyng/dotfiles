#!/usr/bin/env sh

weekday=$(date +%A)

case $weekday in
    Monday)    day=2;;
    Tuesday)   day=3;;
    Wednesday) day=4;;
    Thursday)  day=5;;
    Friday)    day=6;;
    Saturday)  day=7;;
    Sunday)    day=8;;
esac

CAL=$(date '+%d/%m')

CALICON=􀉉

sketchybar --set $NAME icon=$CALICON label="$day $CAL |"
