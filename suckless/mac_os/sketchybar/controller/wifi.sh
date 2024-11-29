#!/bin/bash

WIFI_CONNECTED=􀙇
WIFI_DISCONNECTED=􀙈

update() {
  IP="$(ipconfig getifaddr en0)"

  ICON="$([ -n "$IP" ] && echo "$WIFI_CONNECTED" || echo "$WIFI_DISCONNECTED")"
  LABEL="$([ -n "$IP" ] && echo "$IP" || echo "Disconnected")"
  COLOR="$([ -n "$IP" ] && echo "0xffE0E4DC" || echo "0xff7F7F7F")"

  sketchybar --set $NAME icon="$ICON" label="$LABEL" icon.color="$COLOR" label.color="$COLOR"
}

click() {
  CURRENT_WIDTH="$(sketchybar --query $NAME | jq -r .label.width)"

  WIDTH=0
  if [ "$CURRENT_WIDTH" -eq "0" ]; then
    WIDTH=dynamic
  fi

  sketchybar --animate sin 20 --set $NAME label.width="$WIDTH"
}

case "$SENDER" in
  "wifi_change") update
  ;;
  "mouse.clicked") click
  ;;
esac
