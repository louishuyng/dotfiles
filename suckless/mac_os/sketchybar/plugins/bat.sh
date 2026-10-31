#!/bin/bash
# Battery popup BATTERY (rev 8): charge · power · left · lid · open (the low-power row was dropped by request, 10-02). Opens on clicking the bat cell. Every 30 s and on power change
#   lid button via bat_act.sh lid
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
P="$CONFIG_DIR/plugins"; C="$HOME/.cache/sketchybar"
B=$(pmset -g batt); PCT=$(grep -Eo '[0-9]+%' <<<"$B" | head -1); PCT=${PCT%\%}
AC=0; grep -q "'AC Power'" <<<"$B" && AC=1
REM=$(grep -Eo '[0-9]+:[0-9]+ remaining' <<<"$B" | cut -d' ' -f1)
if grep -q 'charged' <<<"$B" || { [ $AC = 1 ] && [ "${PCT:-0}" -ge 100 ]; }; then ST=full; elif grep -q '; charging' <<<"$B"; then ST=charging; else ST=battery; [ $AC = 1 ] && ST=ac; fi
PC=$TEXT; [ "${PCT:-0}" -le 20 ] && PC=$ERR
case $ST in
  full)     POW="AC  full"; PWC=$TEXT; R="—"; RC=$TEXT2 ;;
  charging) POW="AC  charging"; PWC=$ACCENT; R="${REM:-—} until full"; RC=$TEXT ;;
  ac)       POW="AC"; PWC=$TEXT; R="—"; RC=$TEXT2 ;;
  *)        POW="battery"; PWC=$TEXT; R="${REM:-calculating}"; RC=$TEXT; [ "${PCT:-0}" -le 20 ] && RC=$ERR ;;
esac
if kill -0 "$(cat "$C/caffeinate.pid" 2>/dev/null)" 2>/dev/null; then LID="stays awake when closed"; LC=$TEXT; else LID="sleeps when closed"; LC=$TEXT2; fi
ACT="@CONFIG_DIR='$CONFIG_DIR' bash '$P/bat_act.sh'"
printf 'charge\t%s%%\t%s\t\npower\t%s\t%s\t\nleft\t%s\t%s\t\nlid\t%s\t%s\t%s lid\nopen\tBattery Settings ↗\t%s\topen "x-apple.systempreferences:com.apple.Battery-Settings.extension"\n' \
  "${PCT:-—}" "$PC" "$POW" "$PWC" "$R" "$RC" "$LID" "$LC" "$ACT" "$TEXT2" \
  | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | popup_rows bat BATTERY
# The popup draws left-cell text 1pt above the value text → lower it 1pt (measured)
a=(); for i in 0 1 2 3 4; do a+=(--set bat.p.$i icon.y_offset=-1); done; sketchybar "${a[@]}" 2>/dev/null
