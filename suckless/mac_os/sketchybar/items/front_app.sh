#!/bin/bash

front_app=(
        label.color=0xffFFB654
	# icon.font="sketchybar-app-font:Regular:15"
        # icon.color=0xff17FE52
	label.font="BlexMono Nerd Font:Regular:13.0"
        icon.padding_left=5
	label.padding_left=5
	label.padding_right=5
	background.drawing=on
	background.corner_radius=0
	background.height=22
	script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
	--set front_app "${front_app[@]}" \
	--subscribe front_app front_app_switched
