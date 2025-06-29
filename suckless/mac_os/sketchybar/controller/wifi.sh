#!/bin/bash

WIFI_CONNECTED="Wifi"
WIFI_DISCONNECTED="NoWifi"

IS_DARK_THEME=$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')

update() {
  IP="$(ipconfig getifaddr en0)"

  ICON="$([ -n "$IP" ] && echo "$WIFI_CONNECTED" || echo "$WIFI_DISCONNECTED")"
  LABEL="$([ -n "$IP" ] && echo "$IP" || echo "Disconnected")"

  if [ "$IS_DARK_THEME" = "true" ]; then
    COLOR="$([ -n "$IP" ] && echo "0xFFD3D3D4" || echo "0xFFD3D3D4")"
  else
    COLOR="$([ -n "$IP" ] && echo "0xff000000" || echo "0xff7F7F7F")"
  fi

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
  "theme_change") update
  ;;
esac
