#!/opt/homebrew/bin/bash

ICON_FONT="sketchybar-app-font"

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            icon.font="$ICON_FONT:Regular:20"                 \
                            label.padding_left=2                             \
                            background.padding_left=5 \
                            background.corner_radius=0                \
