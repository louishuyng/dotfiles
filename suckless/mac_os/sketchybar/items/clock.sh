#!/opt/homebrew/bin/bash

clock=(
	update_freq=5
	icon.drawing=off
	script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right \
	--set clock "${clock[@]}"
