#!/bin/bash

front_app=(
	icon.drawing=on
	icon.font="sketchybar-app-font:Regular:15"
	icon.color=0xffA0C980
	label.color=0xffA0C980
        icon.padding_right=5
        icon.padding_left=5
	script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
	--set front_app "${front_app[@]}" \
	--subscribe front_app front_app_switched
