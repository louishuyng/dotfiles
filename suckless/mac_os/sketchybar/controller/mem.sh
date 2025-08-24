#!/opt/homebrew/bin/bash

MEMORY_USAGE="$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5"%") }')%"

sketchybar -m --set $NAME label="$MEMORY_USAGE"
