#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

GREEN=#60ff60
sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            label.font="$LABEL:Bold:13"                     \
                            icon.font="$ICON_FONT:Regular:16"                 \
                            icon.padding_left=5                             \
                            label.padding_left=2                             \
                            label.color=0xff${GREEN:1}                             \
                            icon.color=0xff${GREEN:1}                             \
