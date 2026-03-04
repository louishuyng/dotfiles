#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/plugins/icon_map_fn.sh"

if [ "$SENDER" = "front_app_switched" ]; then
	__icon_map "${INFO}"
	if [ "$icon_result" != ":default:" ]; then
		sketchybar --set "$NAME" label="$INFO" icon="$icon_result"
	else
		sketchybar --set "$NAME" label="$INFO" icon=""
	fi
fi
