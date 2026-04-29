#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

sketchybar --add item pulse left \
	--set pulse \
		label="󱄺" \
		label.font="BlexMono Nerd Font:Bold:26.0" \
		label.padding_left=8 \
		label.padding_right=4 \
		icon.drawing=off \
		background.drawing=off \
		padding_left=0 \
		padding_right=0 \
		update_freq=2 \
		script="$PLUGIN_DIR/pulse.sh"
