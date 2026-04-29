#!/bin/bash

source "$CONFIG_DIR/colors.sh"

front_app=(
	icon.color=$FRONT_APP_COLOR
	icon.font="sketchybar-app-font:Regular:18"
	label.color=$FRONT_APP_COLOR
	icon.padding_left=0
	label.padding_left=5
	label.padding_right=5
	background.drawing=off
	padding_left=5
	script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
	--set front_app "${front_app[@]}" \
	--subscribe front_app front_app_switched
