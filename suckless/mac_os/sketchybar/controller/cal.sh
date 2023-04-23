#!/usr/bin/env sh

CAL=$(date '+%A %d %b')

CALICON=􀉉

sketchybar --set $NAME icon=$CALICON label="$CAL |"
