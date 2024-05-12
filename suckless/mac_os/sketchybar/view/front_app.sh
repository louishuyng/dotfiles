#!/usr/bin/env sh
ICON_FONT="sketchybar-app-font"

APP_LABEL=#60ff60
APP_COLOR=#60ff60
sketchybar --add item space_separator left                              \
           --set space_separator icon="|"                                 \
                                 icon.font="$LABEL:SemiBold:12"         \
                                 background.padding_left=0              \
                                 icon.padding_right=3                             \
                                 label.padding_right=0                             \

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            front_app click_script="open -a 'Mission Control'"          \
                            label.font="$LABEL:Bold:13"                     \
                            icon.font="$ICON_FONT:Regular:15"                 \
                            icon.padding_left=5                             \
                            label.padding_left=2                             \
                            label.color=0xff${APP_LABEL:1}                             \
                            icon.color=0xff${APP_COLOR:1}                             \
