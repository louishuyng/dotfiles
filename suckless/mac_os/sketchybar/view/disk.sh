#!/usr/bin/env sh

sketchybar --add item disk right                              \
           --set disk script="$PLUGIN_DIR/disk.sh"            \
                      icon.font="$LABEL:Bold:18"          \
                      update_freq=30                           \
