#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

# Breathing cycle: dim → bright → dim over ~3s
sketchybar --animate sin 45 --set pulse label.color=$ICON label.color=$ICON_DIM
