#!/bin/bash
# Sums the Dock badge counts.
source "$CONFIG_DIR/config.sh"
T=0
for a in "${NOTIF_APPS[@]}"; do
  n=$(lsappinfo info -only StatusLabel "$a" 2>/dev/null | grep -Eo '"label"="[0-9]+"' | grep -Eo '[0-9]+')
  T=$((T + ${n:-0}))
done
if [ "$T" -gt 0 ]; then sketchybar --set "$NAME" drawing=on label="$T"
else sketchybar --set "$NAME" drawing=off; fi
