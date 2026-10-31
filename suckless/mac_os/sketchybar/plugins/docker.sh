#!/bin/bash
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
LIST=$(docker ps --format '{{.Names}}\t{{.Status}}' 2>/dev/null)
N=$(grep -c . <<<"$LIST")
while IFS=$'\t' read -r name status; do
  [ -n "$name" ] && printf '%s\t%s\t%s\topen -a '"'"'%s'"'"'\n' "${status%% *}" "$name" "$TEXT" "$TERMINAL_APP"
done <<<"$LIST" | popup_rows docker DOCKER
if [ "$N" -gt 0 ]; then sketchybar --set docker drawing=on label="$N"
else sketchybar --set docker drawing=off; fi
