#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

network=(
	update_freq=3
	icon.color=$PURPLE
	label.padding_left=8
	label.color=$PURPLE
	label.padding_right=8
	background.drawing=off
	padding_left=10
	script="$PLUGIN_DIR/network.sh"
)

sketchybar --add item network right \
	--set network "${network[@]}"
