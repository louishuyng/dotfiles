#!/usr/bin/env sh

WIFIACTIVEICON=􀙇
WIFIINACTIVEICON=􀙈

CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"

SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //' | awk '{for(i=1; i<=NF; i++) printf "%s",substr($i,1,1)}')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //' | awk '{print $1/8}')"

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME label="Disconnected |" icon=$WIFIINACTIVEICON
else
  sketchybar --set $NAME label="$SSID 􀍾 ${CURR_TX} Mb/s |" icon=$WIFIACTIVEICON
fi
