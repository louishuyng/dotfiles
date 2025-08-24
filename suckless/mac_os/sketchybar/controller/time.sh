#!/usr/bin/env sh

TIME=$(date '+%H:%M')
CAL=$(date '+%b-%d')

sketchybar --set $NAME label="[$TIME $CAL]"
