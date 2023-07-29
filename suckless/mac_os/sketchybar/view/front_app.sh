#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            label.padding_left=-1                             \
                            label.padding_right=7                             \
                            label.font="$LABEL:Bold:12.5"                     \
                            icon.font="$ICON_FONT:Regular:17"                 \
                            label.y_offset=-1                                 \
                            label.color=0xff${GREEN:1}                             \
                            icon.color=0xff${GREEN:1}                             \
