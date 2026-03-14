#!/opt/homebrew/bin/bash

battery=(
	update_freq=120
	icon.drawing=on
        padding_left=20
        label.padding_left=5
        label.padding_right=10
	script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery system_woke power_source_change
