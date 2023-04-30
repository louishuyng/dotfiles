#!/usr/bin/env sh
sketchybar -m --add item warpvpn left                         \
              --set warpvpn update_freq=5                    \
                    icon.font="$LABEL:Bold:15.0"              \
                    icon.y_offset=1                          \
                    cpu script="$PLUGIN_DIR/warpvpn.sh"       \
