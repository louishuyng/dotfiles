#!/bin/bash
source "$CONFIG_DIR/colors.sh"
if [ "$SELECTED" = "true" ]; then W=20; C=$TEXT; else W=8; C=$TEXT3; fi
sketchybar --animate tanh 12 --set "$NAME" label.width=$W background.color=$C
