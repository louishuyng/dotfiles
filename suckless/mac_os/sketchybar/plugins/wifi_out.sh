#!/bin/bash
# Switch to a saved network from the Wi-Fi popup: wifi_out.sh <row number> <network name>. The status goes at the right end of the row (the ✓ slot) — trying '·  ··  ···' (--text-3) · failure 'failed' (--err) for 3 s
#   same method as vol_out.sh in the volume popup (text image). networksetup returns 0 even on failure, so judge by its output text. Over 20 s = failure
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"; source "$CONFIG_DIR/colors.sh"
C="$HOME/.cache/sketchybar"; L="$C/wifi_out.lock"; ST="$C/wifi_out.st"
[ -e "$L" ] && kill -0 "$(cat "$L")" 2>/dev/null && exit 0; echo $$ > "$L"; echo $$ > "$ST"
row="wifi.p.$1"; W=261
img() { local f="$C/st_$1.png"; [ -f "$f" ] || "$CONFIG_DIR/helper/textpng" "$2" "$3" 12 "$f"; echo "$f"; }
show() { local w; w=$(( $(sips -g pixelWidth "$1" 2>/dev/null | awk '/pixelWidth/{print $2}') / 2 ))
  sketchybar --set "$row" background.image="$1" background.image.scale=0.5 background.image.drawing=on \
    background.image.padding_left=$(( W - 10 - w )) background.image.y_offset=-1; }
clear_st() { sketchybar --set "$row" background.image.drawing=off; }
D1=$(img d1 '·' "$TEXT3"); D2=$(img d2 '··' "$TEXT3"); D3=$(img d3 '···' "$TEXT3"); FAIL=$(img fail 'failed' "$ERR")
CMD=(networksetup -setairportnetwork en0 "$2")
[ -n "$WIFI_OUT_DRY" ] && { printf '%q ' "${CMD[@]}"; echo; rm -f "$L"; exit 0; }   # for testing: just print the command and stop
( while :; do for d in "$D1" "$D2" "$D3"; do show "$d"; sleep 0.4; done; done ) & dots=$!
out=$(perl -e 'alarm 20; exec @ARGV' "${CMD[@]}" 2>&1); rc=$?
kill $dots 2>/dev/null; wait $dots 2>/dev/null
if [ $rc = 0 ] && [ -z "$out" ]; then clear_st; rm -f "$L"; SENDER=forced bash "$CONFIG_DIR/plugins/wifi.sh"; exit 0; fi
show "$FAIL"; rm -f "$L"; sleep 3; [ "$(cat "$ST" 2>/dev/null)" = $$ ] && clear_st
