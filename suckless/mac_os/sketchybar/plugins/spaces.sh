#!/bin/bash
set -e

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/left_label.sh"
resize_left_label wordmark "" spaces.n
