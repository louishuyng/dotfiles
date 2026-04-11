#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
      UPPER=$(echo "$INFO" | tr '[:lower:]' '[:upper:]')
      sketchybar --set "$NAME" label="$UPPER"
fi
