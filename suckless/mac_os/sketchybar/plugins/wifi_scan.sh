#!/bin/bash
# Wi-Fi cell click: open/close the popup + scan nearby only on open (helper/WifiScan.app, about 6 s — 'Scanning …' meanwhile). List again after the scan
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"; C="$HOME/.cache/sketchybar"
bash "$CONFIG_DIR/plugins/popup_click.sh" wifi
[ "$(cat "$C/popup_open" 2>/dev/null)" = wifi ] || exit 0
touch "$C/wifiscan.busy"; SENDER=routine NAME=wifi bash "$CONFIG_DIR/plugins/wifi.sh"
perl -e 'alarm 20; exec @ARGV' "$CONFIG_DIR/helper/WifiScan.app/Contents/MacOS/WifiScan"   # launching the app with open makes the SketchyBar popup disappear (it is not drawn until a real click), so run the executable directly
rm -f "$C/wifiscan.busy"; SENDER=routine NAME=wifi bash "$CONFIG_DIR/plugins/wifi.sh"
