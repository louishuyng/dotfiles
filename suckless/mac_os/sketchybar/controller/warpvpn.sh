#!/bin/bash

# Make a request to the Cloudflare API to get the current Warp VPN status
status=$(curl -s https://1.1.1.1/cdn-cgi/trace | grep warp=)

NORD4="0xffD8DEE9"
GREEN="0xffa6da95"

# Check if the Warp VPN status is "on" or "off"
if [[ $status == *"warp=on"* ]]; then
  sketchybar --set $NAME label="WARP" label.color=$GREEN
else
  sketchybar --set $NAME label="WARP" label.color=$NORD4
fi
