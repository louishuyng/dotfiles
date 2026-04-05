#!/bin/bash

FOCUSED="$FOCUSED_WORKSPACE"
OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

# NAME is like "workspace.Terminal" — extract the workspace name
THIS_WS="${NAME#workspace.}"

if echo "$OCCUPIED" | grep -q "^${THIS_WS}$"; then
	if [ "$THIS_WS" = "$FOCUSED" ]; then
		# Active workspace — bright blue
		sketchybar --set "$NAME" label.color=0xff7aa2f7 drawing=on
	else
		# Occupied but inactive — dim
		sketchybar --set "$NAME" label.color=0xff3b4261 drawing=on
	fi
else
	# Empty — hide
	sketchybar --set "$NAME" drawing=off
fi
