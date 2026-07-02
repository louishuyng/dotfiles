#!/bin/bash

# Local network throughput indicator (download ↓ / upload ↑).
# Polls netstat for the default interface every update_freq seconds.

network=(
  updates=on
  update_freq=2
  label.drawing=on
  padding_right=0
  padding_left=7
  label.padding_right=2
  width=100
  label.font="$FONT:Regular:13.0"
  script="$PLUGIN_DIR/network.sh"
)

sketchybar --add item network left \
  --set network "${network[@]}"
