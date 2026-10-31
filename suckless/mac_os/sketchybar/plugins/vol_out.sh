#!/bin/bash
# Switch output device: vol_out.sh set <deviceID> <row> | vol_out.sh connect <bluetooth address> <row>. Trying · success · failure
# The status goes at the right end of the row (the ✓ slot): while trying '·  ··  ···' cycling every 0.4 s (--text-3), on failure 'failed' (--err), gone after 3 s. The device name color stays
#   one row cannot have two colors, so the status is a text image (helper/textpng) laid on as the row background image
# The verdict is helper/audio's exit code. Not done within 10 s = failure. Clicks on other devices are ignored while trying; clicking again while the failure shows retries at once
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"; source "$CONFIG_DIR/colors.sh"
C="$HOME/.cache/sketchybar"; L="$C/vol_out.lock"; ST="$C/vol_out.st"
[ -e "$L" ] && kill -0 "$(cat "$L")" 2>/dev/null && exit 0; echo $$ > "$L"; echo $$ > "$ST"
row="vol.ul.p.$(( $3 + 1 ))"   # 0 = mute, 1 = OUTPUT, 2~ = devices
W=261
img() { # <name> <text> <color> → image path (cached)
  local f="$C/st_$1.png"; [ -f "$f" ] || "$CONFIG_DIR/helper/textpng" "$2" "$3" 12 "$f"; echo "$f"; }
show() { # <image> — right end aligned to padding 12
  local w; w=$(( $(sips -g pixelWidth "$1" 2>/dev/null | awk '/pixelWidth/{print $2}') / 2 ))
  sketchybar --set "$row" background.image="$1" background.image.scale=0.5 background.image.drawing=on \
    background.image.padding_left=$(( W - 10 - w )) background.image.y_offset=-1; }   # measured in a popup (tailscale popup): the image is 1pt above the text with a right margin of 2 → −1 · +2
clear_st() { sketchybar --set "$row" background.image.drawing=off; }
D1=$(img d1 '·' "$TEXT3"); D2=$(img d2 '··' "$TEXT3"); D3=$(img d3 '···' "$TEXT3"); FAIL=$(img fail 'failed' "$ERR")
( while :; do for d in "$D1" "$D2" "$D3"; do show "$d"; sleep 0.4; done; done ) & dots=$!
perl -e 'alarm 10; exec @ARGV' "$CONFIG_DIR/helper/audio" "$1" "$2"; rc=$?
kill $dots 2>/dev/null; wait $dots 2>/dev/null
if [ $rc = 0 ]; then clear_st; rm -f "$L"; SENDER=routine bash "$CONFIG_DIR/plugins/vol.sh"; exit 0; fi
show "$FAIL"; rm -f "$L"
sleep 3; [ "$(cat "$ST" 2>/dev/null)" = $$ ] && clear_st   # if clicked again meanwhile, the new attempt owns this row
