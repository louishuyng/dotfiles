#!/opt/homebrew/bin/bash

workspace=(
	label="?"
	icon.drawing=on
        icon.padding_right=5
	padding_left=0
	padding_right=0
	script="$PLUGIN_DIR/workspace.sh"
)

sketchybar --add item workspace left \
	--set workspace "${workspace[@]}" \
	--subscribe workspace aerospace_workspace_change
