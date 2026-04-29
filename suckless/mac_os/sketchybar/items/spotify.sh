#!/opt/homebrew/bin/bash

spotify=(
	update_freq=5
	icon.padding_left=8
	icon.padding_right=6
	label.padding_right=3
        icon.font="BlexMono Nerd Font:Bold:18.0"
	# background.drawing=on
	# background.color=0xff241830
	# background.corner_radius=6
	# background.height=22
        padding_right=0
	drawing=off
	click_script="open -a Spotify"
	script="$PLUGIN_DIR/spotify.sh"
)

sketchybar --add item spotify right \
	--set spotify "${spotify[@]}" \
	--subscribe spotify system_woke mouse.entered mouse.exited
