#!/usr/bin/env bash

MEMORY_USAGE="$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5"%") }')%"

COLOR=#9BE89F
sketchybar -m --set $NAME icon="RAM" label="$MEMORY_USAGE |" icon.color=0xff${COLOR:1}
