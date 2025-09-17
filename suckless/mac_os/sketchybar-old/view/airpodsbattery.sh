#!/opt/homebrew/bin/bash

sketchybar --add item airpods right                                \
           --set      airpods update_freq=10                       \
                      script="$PLUGIN_DIR/airpodsbattery.sh"       \
