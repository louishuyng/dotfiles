#!/bin/bash

source "$CONFIG_DIR/colors.sh"

FOCUSED="$FOCUSED_WORKSPACE"
OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

THIS_WS="${NAME#workspace.}"

if echo "$OCCUPIED" | grep -q "^${THIS_WS}$"; then
	if [ "$THIS_WS" = "$FOCUSED" ]; then
		# Active — bright green
		sketchybar --animate tanh 15 --set "$NAME" label.color=$GREEN drawing=on
	else
		# Occupied but inactive — dim green
		sketchybar --animate tanh 15 --set "$NAME" label.color=$GREEN_DIM drawing=on
	fi
else
	sketchybar --set "$NAME" drawing=off
fi
