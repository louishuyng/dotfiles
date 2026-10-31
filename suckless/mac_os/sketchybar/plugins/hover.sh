#!/bin/bash
# settings circle hover: glyph --text-3 → --text
source "$CONFIG_DIR/colors.sh"
case "$SENDER" in mouse.entered) sketchybar --set "$NAME" icon.color=$TEXT ;; mouse.exited) sketchybar --set "$NAME" icon.color=$TEXT3 ;; esac
