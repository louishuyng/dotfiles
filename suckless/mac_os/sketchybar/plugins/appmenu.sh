#!/bin/bash
# App-menu popup (rev 10 §1): clicking the app name cell (front_app) shows the front app's menus. Width 248
#   title = app name · Settings… (top, 6 gap below) · menu name rows (›/−) · under the expanded menu '└ item  shortcut'. Only one expanded at a time
#   menus are read with helper/axmenu (Accessibility API) only on an app-name click (no pre-reading on app switch) — drawn at once from a per-app cache, then re-read in the background to refresh
#   appmenu.sh render | refresh | toggle <menu no.> | press <menu no.> <item no.> [pid at draw time] | settings
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"; source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
P="$CONFIG_DIR/plugins"; H="$CONFIG_DIR/helper"; C="$HOME/.cache/sketchybar/appmenu"; mkdir -p "$C"
IFS=$'\t' read -r PID NAME < <("$CONFIG_DIR/helper/axmenu" front)
KEY="$C/$(printf '%s' "$NAME" | md5 | cut -c1-12)"; EXP="$C/expanded"
refresh() { [ -n "$PID" ] && perl -e 'alarm 5; exec @ARGV' "$H/axmenu" menus "$PID" > "$KEY.tmp" 2>/dev/null && [ -s "$KEY.tmp" ] && mv "$KEY.tmp" "$KEY"; rm -f "$KEY.tmp"; }
W=248; ROWS=32
img() { local f="$HOME/.cache/sketchybar/ti/$(printf '%s|%s|t' "$1" "$2" | md5 | cut -c1-12).png" o=trim; [ "$1" = "−" ] && o="trim sys"   # trim to ink width to align the right edge
  mkdir -p "${f%/*}"; [ -f "$f" ] || "$H/textpng" "$1" "$2" 12 "$f" $o; echo "$f"; }
render() {
  local ex; ex=$(cat "$EXP" 2>/dev/null); [ "$(cut -f1 <<<"$ex")" = "$NAME" ] && ex=$(cut -f2 <<<"$ex") || ex=""
  local rows=() rights=() bgs=() i=0
  local ACT="@CONFIG_DIR='$CONFIG_DIR' bash '$P/appmenu.sh'"
  rows+=("_"$'\t'"Settings…"$'\t'"$TEXT"$'\t'"CONFIG_DIR='$CONFIG_DIR' bash '$P/appmenu.sh' settings"); rights+=("⌘,|$TEXT3"); bgs+=("")
  while IFS=$'\t' read -r k a b c d e; do
    case "$k" in
      M) rows+=("_"$'\t'"$b"$'\t'"$TEXT2"$'\t'"$ACT toggle $a"); [ "$a" = "$ex" ] && { rights+=("−|$TEXT3"); bgs+=("$BG2"); } || { rights+=("›|$TEXT3"); bgs+=(""); } ;;
      I) [ "$a" = "$ex" ] || continue
         if [ "$d" = 1 ]; then rows+=("_"$'\t'"└ $c"$'\t'"$TEXT"$'\t'"CONFIG_DIR='$CONFIG_DIR' bash '$P/appmenu.sh' press $a $b $PID")
         else rows+=("_"$'\t'"└ $c"$'\t'"$TEXT3"$'\t'); fi
         rights+=("${e:+$e|$TEXT3}"); bgs+=("") ;;
    esac
  done < <(cat "$KEY" 2>/dev/null)
  [ -s "$KEY" ] || { rows+=("_"$'\t'"Reading menus …"$'\t'"$TEXT3"$'\t'); rights+=(""); bgs+=(""); }
  { for r in "${rows[@]:0:$ROWS}"; do printf '%s\n' "$r"; done; for ((j=${#rows[@]}; j<ROWS; j++)); do printf '~\t.\t\t\n'; done; } \
    | perl "$P/fit.pl" 170 | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | POPUP_W=$W popup_rows front_app "$(tr '[:lower:]' '[:upper:]' <<<"$NAME")"
  # right-side symbols and shortcuts (--text-3) are text images (ink width) with right edge = popup right − 12 (two colors on one row). Expanded menu row background --bg-2. 6 gap below Settings…
  local a=() f w
  for ((i=0; i<ROWS; i++)); do
    a+=(--set front_app.p.$i background.image.drawing=off background.color=${bgs[$i]:-0x00000000} label.y_offset=0 background.height=24)
    if [ -n "${rights[$i]}" ]; then f=$(img "${rights[$i]%|*}" "${rights[$i]#*|}"); w=$(( $(sips -g pixelWidth "$f" | awk '/pixelWidth/{print $2}') / 2 ))
      a+=(--set front_app.p.$i background.image="$f" background.image.scale=0.5 background.image.drawing=on background.image.padding_left=$(( W - 11 - w )) background.image.y_offset=-1); fi   # measured (10-06): ink edge = popup outer right − 12
  done
  a+=(--set front_app.p.0 background.height=30 label.y_offset=3)
  sketchybar "${a[@]}" 2>/dev/null
}
case "$1" in
  refresh) refresh; [ "$(cat "$POPUP_OPEN" 2>/dev/null)" = front_app ] && render ;;
  toggle) cur=$(cat "$EXP" 2>/dev/null); [ "$cur" = "$NAME"$'\t'"$2" ] && rm -f "$EXP" || printf '%s\t%s' "$NAME" "$2" > "$EXP"; render ;;
  press) popup_close_all; [ -n "$4" ] && [ "$4" != "$PID" ] && exit 0; "$H/axmenu" press "$PID" "$2" "$3" ;;   # do not press if the front app changed after drawing (avoids the same number in another app)
  settings) popup_close_all; "$H/axmenu" settings "$PID" || osascript -e 'tell application "System Events" to keystroke "," using command down' ;;
  open) rm -f "$EXP"; render; bash "$P/popup_click.sh" front_app; [ "$(cat "$POPUP_OPEN" 2>/dev/null)" = front_app ] && { refresh; render; } ;;
  *) render ;;
esac
