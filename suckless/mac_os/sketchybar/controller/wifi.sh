#!/usr/bin/env sh
#
WIFIACTIVEICON=􀙇
WIFIINACTIVEICON=􀙈

CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //' | awk '{for(i=1; i<=NF; i++) printf "%s",substr($i,1,1)}')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME label="Disconnected |" icon=$WIFIINACTIVEICON
else
  SPEED=$(awk -v num="$CURR_TX" 'BEGIN{ printf "%.2f MBps", num/8 }')

  sketchybar --set $NAME label="$SSID $SPEED |" icon=$WIFIACTIVEICON
fi
