#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            icon.font="$ICON_FONT:Regular:17"                 \
                            icon.padding_left=7                             \
                            label.padding_right=7                             \
                            label.padding_left=0                             \
                            background.corner_radius=0                \
                            background.drawing=on                    \
