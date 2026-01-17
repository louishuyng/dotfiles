#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

sketchybar --set "$NAME" icon.font="$FONT:Regular:19.0" \
                        label="$FOCUSED_WORKSPACE" \
                        label.color=$YELLOW \
                        padding_right=0 \
                        padding_left=0 \
                        background.drawing=off \
                        label.drawing=on
