#!/usr/bin/env sh

ICON_FONT="sketchybar-app-font"

APP_LABEL=#40A02B
APP_BG_COLOR=#000000

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            front_app click_script="open -a 'Mission Control'"          \
                            label.font="$LABEL:Bold:13"                     \
                            icon.font="$ICON_FONT:Regular:15"                 \
                            icon.padding_left=7                             \
                            label.padding_left=0                             \
                            label.color=0xff${APP_LABEL:1}                             \
                            icon.color=0xff${APP_LABEL:1}                              \
                            background.corner_radius=0                \
                            background.color=0xff${APP_BG_COLOR:1}       \
                            background.drawing=on                    \
