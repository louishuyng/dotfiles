#!/bin/bash

front_app=(
        icon.color=0xffD8DBE0
	icon.font="sketchybar-app-font:Regular:15"
        icon.color=0xffD8DBE0
	label.font="BlexMono Nerd Font:Bold:13.0"
        icon.padding_left=5
	label.padding_left=5
	label.padding_right=5
	background.drawing=on
        background.color=0xff2E3440
	background.corner_radius=0
	background.height=24
	script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
	--set front_app "${front_app[@]}" \
	--subscribe front_app front_app_switched
