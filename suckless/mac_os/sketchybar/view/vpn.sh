#!/usr/bin/env sh
sketchybar -m --add item vpn left                         \
              --set vpn update_freq=5                    \
                    icon.y_offset=1                          \
                    icon.font="$LABEL:Bold:17.0"              \
                    cpu script="$PLUGIN_DIR/vpn.sh"       \
