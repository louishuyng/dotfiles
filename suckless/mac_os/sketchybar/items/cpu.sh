#!/opt/homebrew/bin/bash

# RAM added first = rightmost position (right side items: first added = rightmost)
# But we want CPU left of RAM, so add RAM first
sketchybar --add item ram right \
	--set ram \
		update_freq=5 \
		icon.drawing=off \
		label="R:0%" \
		label.color=0xff9ece6a \
		label.padding_left=2 \
		label.padding_right=4 \
		script="$PLUGIN_DIR/ram.sh"

sketchybar --add item cpu right \
	--set cpu \
		update_freq=5 \
		icon.drawing=off \
		label="C:0%" \
		label.color=0xfff7768e \
		label.padding_left=4 \
		label.padding_right=2 \
		script="$PLUGIN_DIR/cpu.sh"

sketchybar --add bracket cpu_ram cpu ram \
	--set cpu_ram \
		# background.drawing=on \
		# background.color=0xff16161E \
		# background.corner_radius=6 \
		# background.height=22
