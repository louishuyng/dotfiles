#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  sketchybar --set $NAME icon.color=$BLUE
else
  sketchybar --set $NAME icon.color=$GREY
fi
