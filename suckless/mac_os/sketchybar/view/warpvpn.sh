#!/usr/bin/env sh
sketchybar -m --add item warpvpn left                         \
              --set warpvpn update_freq=5                    \
                    label.padding_left=-1                          \
                    icon.font="$LABEL:Bold:15.0"              \
                    cpu script="$PLUGIN_DIR/warpvpn.sh"       \
