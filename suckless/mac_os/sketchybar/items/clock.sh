#!/opt/homebrew/bin/bash

clock=(
	update_freq=1
	icon.drawing=off
	label.color=0xffe0af68
	label.padding_left=5
	label.padding_right=10
	# background.drawing=on
	# background.color=0xff241c00
	# background.corner_radius=6
	# background.height=22
        padding_right=0
	script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
	--set clock "${clock[@]}"
