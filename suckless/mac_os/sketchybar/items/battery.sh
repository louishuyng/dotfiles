#!/opt/homebrew/bin/bash

battery=(
	update_freq=60
	label.padding_left=3
	label.padding_right=0
	background.drawing=off
	script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery system_woke power_source_change
