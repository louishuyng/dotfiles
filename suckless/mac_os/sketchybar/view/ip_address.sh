#!/usr/bin/env sh

sketchybar --add item  ip_address left                              \
           --set       ip_address script="$PLUGIN_DIR/ip_address.sh" \
                                  update_freq=30                     \
                                  padding_left=2                     \
                                  icon.font="$LABEL:Bold:20"          \
           --subscribe ip_address wifi_change                        \
