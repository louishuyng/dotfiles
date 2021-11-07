#!/bin/bash

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  sketchybar -m set vpn icon 
  sketchybar -m set vpn label "$VPN"
else
  sketchybar -m set vpn icon
  sketchybar -m set vpn label
fi
