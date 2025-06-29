#!/usr/bin/env sh

sketchybar --add item    battery right                                  \
           --subscribe   battery system_woke                            \
           --set battery update_freq=20                                  \
                         label.padding_left=0                             \
                         label.padding_right=10                             \
                         script="$PLUGIN_DIR/battery.sh"                \
