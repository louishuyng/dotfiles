#!/bin/bash

# Make a request to the Cloudflare API to get the current Warp VPN status
status=$(curl -s https://1.1.1.1/cdn-cgi/trace | grep warp=)

ONICON=􀙶
OFFICON=􀌏

# Check if the Warp VPN status is "on" or "off"
if [[ $status == *"warp=on"* ]]; then
  sketchybar --set $NAME icon=$ONICON
else
  sketchybar --set $NAME icon=$OFFICON
fi
