#!/bin/bash
# Close all open popups when switching to another app or when the space or display layout changes.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/plugins/popup.sh"
# display_change also fires when the front window moves to another display (even from one click on another display's bar).
# Ignore it if the display layout is unchanged — otherwise the popup just opened closes and the whole bar reloads.
if [ "$SENDER" = display_change ]; then
  D="$HOME/.cache/sketchybar/displays"; now_d=$(sketchybar --query displays | md5)
  [ "$now_d" = "$(cat "$D" 2>/dev/null)" ] && exit 0
  echo "$now_d" > "$D"
  # The display setup really changed: measure the bar display and notch again so the notch width and the media island end follow (main display switching between a notch display and an external one). No full --reload
  source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/display.sh"
  sketchybar --bar notch_width=$NOTCH_W --trigger media_layout
fi
# After a display change or wake the bar sometimes ends up with no windows, so check 6s later and restart if needed (health.sh, at most once per 5 minutes)
case "$SENDER" in display_change|system_woke) (sleep 6; SENDER="$SENDER" nohup bash "$CONFIG_DIR/plugins/health.sh" >/dev/null 2>&1 &) ;; esac
# keep the popup when the scan app (no window) launched by the Wi-Fi popup briefly becomes the front app
[ "$SENDER" = front_app_switched ] && case "$INFO" in "SketchyBar Wi-Fi Scan"|WifiScan) exit 0 ;; esac
popup_close_all
# no full reload (--reload) or full script re-run (--update) on a display layout change or wake from sleep (10-07):
#   SketchyBar rebuilds the bar and item windows itself then and the values stay. Time-sensitive cells (clock, calendar, battery, wifi etc.) subscribe to system_woke separately
