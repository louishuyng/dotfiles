#!/usr/bin/env sh

sketchybar --add item       front_app left                                    \
           --subscribe      front_app front_app_switched                      \
           --set            front_app script="$PLUGIN_DIR/front_app.sh"       \
                            label.padding_left=-1                             \
                            label.font="$LABEL:Bold:13.0"                     \
                            label.color=0xff${MAGENTA:1}                             \
                            icon.color=0xff${MAGENTA:1}                             \
