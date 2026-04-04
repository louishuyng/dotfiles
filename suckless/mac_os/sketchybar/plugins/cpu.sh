#!/opt/homebrew/bin/bash

CPU=$(top -l 2 -n 0 -F | grep "CPU usage" | tail -1 | awk '{print $3}' | cut -d'%' -f1 2>/dev/null)
CPU=$(printf "%.0f" "${CPU:-0}")

sketchybar --set "$NAME" label="C:${CPU}%"
