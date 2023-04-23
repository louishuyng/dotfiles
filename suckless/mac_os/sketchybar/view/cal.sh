#!/usr/bin/env sh

sketchybar --add item   cal right                                     \
           --set cal    update_freq=180                               \
                        script="$PLUGIN_DIR/cal.sh"                   \
