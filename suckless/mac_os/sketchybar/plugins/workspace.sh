#!/bin/bash

source "$CONFIG_DIR/colors.sh"

FOCUSED="$FOCUSED_WORKSPACE"
OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

THIS_WS="${NAME#workspace.}"

if echo "$OCCUPIED" | grep -q "^${THIS_WS}$"; then
	if [ "$THIS_WS" = "$FOCUSED" ]; then
		# Active — theme-specific high-contrast color
		sketchybar --animate tanh 15 --set "$NAME" label.color=$WORKSPACE_ACTIVE_COLOR drawing=on
	else
		# Occupied but inactive — readable, but clearly less prominent
		sketchybar --animate tanh 15 --set "$NAME" label.color=$WORKSPACE_INACTIVE_COLOR drawing=on
	fi
else
	sketchybar --set "$NAME" drawing=off
fi
