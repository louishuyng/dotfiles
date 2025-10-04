#!/opt/homebrew/bin/bash

DISK=$(df -H | head -2 | tail -1 | awk '{print $4}')

sketchybar --set $NAME label="$DISK"
