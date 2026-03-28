#!/opt/homebrew/bin/bash

battery=(
	update_freq=120
	icon.drawing=on
	label.drawing=on
	icon.padding_left=4
	icon.padding_right=3
	padding_left=20
	label.padding_left=0
	label.padding_right=10
	script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery system_woke power_source_change
