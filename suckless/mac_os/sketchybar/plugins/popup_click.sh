#!/bin/bash
# On a bar item click: close the other popups and open/close only this one. The contents are already built.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/popup.sh"
popup_toggle "$1"
