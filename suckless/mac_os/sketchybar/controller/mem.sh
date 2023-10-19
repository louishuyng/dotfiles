#!/usr/bin/env bash

MEMICON=􀫦
MEMORY_USAGE=$(ps -A -o %mem | awk '{ mem += $1} END {print mem}')

GREEN=#60ff60
sketchybar -m --set $NAME icon=$MEMICON label="$MEMORY_USAGE% |" label.color=0xff${GREEN:1} icon.color=0xff${GREEN:1}
