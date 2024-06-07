#!/usr/bin/env sh

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            front_app click_script="open -a 'Mission Control'"          \
                            label.font="$LABEL:Bold:13"                     \
                            icon.padding_left=2                             \
