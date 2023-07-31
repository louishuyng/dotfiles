#!/bin/bash

NORD4="0xffD8DEE9"
GREEN="0xffa6da95"

ONICON=􁅏
OFFICON=􀤆

vpn_status=$(scutil --nc list | grep Connected)

# Check if the VPN status is "on" or "off"
if [[ -n $vpn_status ]]; then
  sketchybar --set $NAME icon.color=$GREEN icon=$ONICON
else
  sketchybar --set $NAME icon.color=$NORD4 icon=$OFFICON
fi
