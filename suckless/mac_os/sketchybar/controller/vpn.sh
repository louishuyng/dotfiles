#!/usr/bin/env sh

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

BLUE=0xff4F54BB
GREY=0xff7F7F7F

if [[ $VPN != "" ]]; then
  sketchybar --set $NAME icon.color=$BLUE icon=􁃗  label="VPN On"
else
  sketchybar --set $NAME label="No VPN" icon.color=$GREY icon=
fi
