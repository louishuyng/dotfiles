#!/usr/bin/env sh

TIME=$(date '+%H:%M')
CAL=$(date '+%d/%m')

sketchybar --set $NAME label="$CAL $TIME"
