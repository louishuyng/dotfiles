#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

sketchybar --add item separator left \
	--set separator \
		label="⠋" \
		label.font="BlexMono Nerd Font:Bold:15.0" \
		label.color=$GREEN \
		label.padding_left=4 \
		label.padding_right=2 \
		icon.drawing=off \
		background.drawing=off \
		padding_left=0 \
		padding_right=0 \
		update_freq=1 \
		script="$PLUGIN_DIR/separator.sh"
