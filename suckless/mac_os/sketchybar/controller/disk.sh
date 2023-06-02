#!/usr/bin/env sh

DISK=$(df -H | head -2 | tail -1 | awk '{print $4}')

DISKICON=􀤂

YELLOW=#ffff00
sketchybar -m --set $NAME icon=$DISKICON label="$DISK |" label.color=0xff${YELLOW:1} icon.color=0xff${YELLOW:1}
