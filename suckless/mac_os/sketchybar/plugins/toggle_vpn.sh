#!/opt/homebrew/bin/bash

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
  if [[ $VPN == *"NordVPN"* ]]; then
    /usr/bin/open -a "NordVPN"
  elif [[ $VPN == *"regask"* ]]; then
    /usr/bin/open -a "Azure VPN Client"
  fi
else
    /usr/bin/open -a "Azure VPN Client"
fi
