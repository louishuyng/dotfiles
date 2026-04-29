#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

clock=(
	update_freq=30
	icon.drawing=off
	label.color=$WHITE
	label.padding_left=5
	label.padding_right=10
	background.drawing=off
	padding_right=0
	script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
	--set clock "${clock[@]}"
