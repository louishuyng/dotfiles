#!/opt/homebrew/bin/bash

# Items added in reverse order (right side: first added = rightmost)
# Display order left→right: C R D
sketchybar --add item disk right \
	--set disk \
		update_freq=60 \
		icon.drawing=off \
		label="D:0" \
		label.color=0xffe0af68 \
		label.padding_left=2 \
		label.padding_right=6 \
		script="$PLUGIN_DIR/disk.sh"

sketchybar --add item ram right \
	--set ram \
		update_freq=5 \
		icon.drawing=off \
		label="R:0%" \
		label.color=0xff9ece6a \
		label.padding_left=2 \
		label.padding_right=2 \
		script="$PLUGIN_DIR/ram.sh"

sketchybar --add item cpu right \
	--set cpu \
		update_freq=5 \
		icon.drawing=off \
		label="C:0%" \
		label.color=0xfff7768e \
		label.padding_left=6 \
		label.padding_right=2 \
		script="$PLUGIN_DIR/cpu.sh"

sketchybar --add bracket cpu_ram cpu disk ram \
	--set cpu_ram \
		background.drawing=on \
		background.color=0xff2A2A2A \
		background.corner_radius=6 \
		background.height=22
