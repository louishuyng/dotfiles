#!/opt/homebrew/bin/bash

battery=(
	update_freq=120
	icon.drawing=on
        icon.padding_left=0
	padding_right=10
	script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery system_woke power_source_change
