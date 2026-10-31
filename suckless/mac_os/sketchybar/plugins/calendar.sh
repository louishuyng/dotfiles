#!/bin/bash
# Next event — the first of today's timed events starting within 1 hour (CAL_WINDOW_MIN): "14:30 meeting +8m", or now if in progress.
# The popup (TODAY) lists today's remaining timed events. All-day events excluded, all calendars. helper/events reads Apple Calendar directly.
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
[ "${CAL_NEXT:-0}" = 1 ] || { sketchybar --set cal drawing=off; exit 0; }   # off by default - CAL_NEXT in config.sh
EVENTS=$("$CONFIG_DIR/helper/events" today 2>/dev/null)
while IFS=$'\t' read -r t title; do
  [ -n "$t" ] && printf '%s\t%s\t%s\topen -a Calendar\n' "$t" "$title" "$TEXT"
done <<<"$EVENTS" | popup_rows cal TODAY
L=$(head -n1 <<<"$EVENTS")
[ -z "$L" ] && { sketchybar --set cal drawing=off; exit 0; }
START="${L%%	*}"; TITLE="${L#*	}"
MIN=$(( ( $(date -j -f "%H:%M" "$START" +%s) - $(date +%s) ) / 60 ))
[ "$MIN" -gt "$CAL_WINDOW_MIN" ] && { sketchybar --set cal drawing=off; exit 0; }
[ "$MIN" -le 0 ] && WHEN="now" || WHEN="+${MIN}m"
sketchybar --set cal drawing=on icon="$START" label="$TITLE $WHEN"
