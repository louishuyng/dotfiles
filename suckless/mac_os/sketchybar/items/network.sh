#!/opt/homebrew/bin/bash

network=(
	update_freq=3
	icon.color=0xff7aa2f7
	label.padding_left=8
	label.color=0xff7aa2f7
	label.padding_right=8
	background.drawing=on
	background.color=0xff101824
	background.corner_radius=6
	background.height=22
        padding_left=10
	script="$PLUGIN_DIR/network.sh"
)

sketchybar --add item network right \
	--set network "${network[@]}"
