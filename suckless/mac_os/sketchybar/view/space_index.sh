#!/usr/bin/env sh

APP_LABEL=#ffffff
APP_COLOR=#ffffff

sketchybar --add item       space_index left                                    \
           --subscribe      space_index space_change                      \
           --set            space_index script="$PLUGIN_DIR/space_index.sh"       \
                            space_index click_script="open -a 'Mission Control'"          \
                            label.font="$LABEL:Bold:13"                     \
                            icon.padding_left=5                             \
                            label.padding_left=2                             \
                            label.color=0xff${APP_LABEL:1}                             \
                            icon.color=0xff${APP_COLOR:1}                             \
