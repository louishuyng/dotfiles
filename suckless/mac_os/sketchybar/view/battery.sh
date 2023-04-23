#!/usr/bin/env sh

sketchybar --add item    battery right                                  \
           --subscribe   battery system_woke                            \
           --set battery update_freq=20                                  \
                         script="$PLUGIN_DIR/battery.sh"                \
