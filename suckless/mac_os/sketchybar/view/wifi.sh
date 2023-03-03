#!/usr/bin/env sh

sketchybar --add item wifi right                      \
           --set wifi update_freq=5                   \
                      script="$PLUGIN_DIR/wifi.sh"    \
