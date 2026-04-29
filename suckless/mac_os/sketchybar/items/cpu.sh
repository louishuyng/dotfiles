#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

# Display order left->right: C R D
sketchybar --add item disk right \
	--set disk \
		update_freq=60 \
		icon.drawing=off \
		label="D:0" \
		label.color=$AMBER \
		label.padding_left=2 \
		label.padding_right=0 \
		script="$PLUGIN_DIR/disk.sh"

sketchybar --add item ram right \
	--set ram \
		update_freq=5 \
		icon.drawing=off \
		label="R:0%" \
		label.color=$GREEN \
		label.padding_left=2 \
		label.padding_right=2 \
		script="$PLUGIN_DIR/ram.sh"

# cpu item: label is updated by the autonomous helper daemon (see sketchybarrc).
sketchybar --add item cpu right \
	--set cpu \
		icon.drawing=off \
		label="C:0%" \
		label.color=$RED_SOFT \
		label.padding_left=6 \
		label.padding_right=2
