#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            front_app click_script="open -a 'Mission Control'"          \
                            label.font="$LABEL:Bold:13"                     \
                            icon.font="$ICON_FONT:Regular:15"                 \
                            icon.padding_left=7                             \
