#!/usr/bin/env bash

MEMICON=􀫦
MEMORY_USAGE=$(ps -A -o %mem | awk '{ mem += $1} END {print mem}')

sketchybar -m --set $NAME icon=$MEMICON label="$MEMORY_USAGE% |"
