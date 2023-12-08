#!/usr/bin/env sh
GREEN=#60ff60
sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            label.font="$LABEL:Bold:12"                     \
                            icon.padding_left=0                             \
                            label.padding_left=0                             \
                            label.color=0xff${GREEN:1}                             \
                            icon.color=0xff${GREEN:1}                             \
