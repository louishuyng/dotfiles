#!/usr/bin/env sh

DISK=$(df -H | head -2 | tail -1 | awk '{print $4}')

YELLOW=#E2C697

sketchybar -m --set $NAME icon="􀥾" label="$DISK |" icon.color=0xff${YELLOW:1}
