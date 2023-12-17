#!/usr/bin/env sh

DISK=$(df -H | head -2 | tail -1 | awk '{print $4}')

YELLOW=#ffff00
sketchybar -m --set $NAME label="D:$DISK |" label.color=0xff${YELLOW:1}
