#!/usr/bin/env sh

sketchybar --add item disk right                              \
           --set disk script="$PLUGIN_DIR/disk.sh"            \
                      label.padding_left=0                           \
                      update_freq=300                           \
