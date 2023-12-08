#!/usr/bin/env sh

TIME=$(date '+%H:%M')
CAL=$(date '+%d/%m')

CLOCKICON=􀐱

sketchybar --set $NAME icon=$CLOCKICON label="$CAL $TIME"
