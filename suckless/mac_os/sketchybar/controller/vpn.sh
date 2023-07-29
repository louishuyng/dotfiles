#!/bin/bash

NORD4="0xffD8DEE9"
GREEN="0xffa6da95"

ONICON=􁅏
OFFICON=􀤆

# Check if the VPN status is "on" or "off"
if netstat -rn | grep -q "^0.0.0.0.*tun\|tap"; then
  sketchybar --set $NAME icon.color=$GREEN icon=$ONICON
else
  sketchybar --set $NAME icon.color=$NORD4 icon=$OFFICON
fi
