#!/bin/bash
# wifi:ssid. Popup: ssid · ip · router · settings. When disconnected: wifi:off (err).
# Wi-Fi name: macOS does not give the name to programs without location permission (<redacted>). Two ways, whichever works:
#   1) run sudo ipconfig setverbose 1 once → ipconfig returns the name
#   2) optional — a Shortcuts shortcut named "SketchyBar Wi-Fi" that returns the current network name can be used as a fallback for the SSID
# The shortcut is slow (around 0.3 s), so it is run only on network change, on wake and at start; the name is kept in a file.
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
IF=en0
IP=$(ipconfig getifaddr $IF)
NAMEF="$HOME/.cache/sketchybar/ssid"
SSID=$(ipconfig getsummary $IF 2>/dev/null | awk -F ' SSID : ' '/ SSID : /{print $2}')
if [ -z "$SSID" ] || [ "$SSID" = "<redacted>" ]; then
  SSID=""
  case "$SENDER" in
    wifi_change|system_woke|forced)   # run hangs when the shortcut does not exist, so check the list first + 5 s limit
      shortcuts list 2>/dev/null | grep -qx "SketchyBar Wi-Fi" \
        && SSID=$(perl -e 'alarm 5; exec @ARGV' shortcuts run "SketchyBar Wi-Fi" 2>/dev/null | head -1)
      echo "$SSID" > "$NAMEF" ;;
    *) SSID=$(cat "$NAMEF" 2>/dev/null) ;;
  esac
fi
[ -z "$IP" ] && SSID=""

# popup WI-FI (width 261, same frame as the volume popup): ssid · ip · router · NETWORKS (saved networks in range now, max 4 · ✓ right of the current one) · settings
#   clicking a saved network makes wifi_out.sh switch to it (uses the keychain password). No browsing of nearby networks and no password entry for new ones — names are hidden from apps without location permission (confirmed 10-02)
W=261; VW=$(( W - 64 - 12 )); NF="JetBrainsMono Nerd Font Propo"; G_WIFI=$'\xf3\xb0\x96\xa9'
right() { local s=$(( ((VW - $(perl "$CONFIG_DIR/plugins/width.pl" "$1") - 7) * 10 + 36) / 72 )); [ $s -lt 1 ] && s=1; printf '%s%*s✓' "$1" $s ''; }
# only saved networks that are in range now (strongest first, current one on top). Nearby names are scanned by a location-permitted app (helper/WifiScan.app) only when the popup opens
#   wifi_scan.sh leaves a scanning marker file (wifiscan.busy), runs the app, then calls this again. No constant polling — while closed, the last result stays
SC="$HOME/.cache/sketchybar/wifiscan.txt"; BUSY="$HOME/.cache/sketchybar/wifiscan.busy"
SAVED=$(networksetup -listpreferredwirelessnetworks $IF 2>/dev/null | tail -n +2 | sed 's/^[[:space:]]*//')
SCST=$(head -1 "$SC" 2>/dev/null)
NETS=$(python3 -c 'import sys
saved=[l for l in sys.argv[1].split("\n") if l]; cur=sys.argv[2]
scan={}
for l in open(sys.argv[3]).read().split("\n")[1:]:
  if "\t" in l: n,r=l.rsplit("\t",1); scan[n]=int(r)
vis=[n for n in saved if n in scan]
vis.sort(key=lambda n:(n!=cur, -scan[n]))
for n in vis[:4]: print("%s\t%d" % (n, scan[n]))' "$SAVED" "$SSID" "$SC" 2>/dev/null)
glyph() { # RSSI → Wi-Fi strength glyph, 4 levels
  if [ "$1" -ge -55 ]; then printf '\xf3\xb0\xa4\xa8'; elif [ "$1" -ge -65 ]; then printf '\xf3\xb0\xa4\xa5'; elif [ "$1" -ge -75 ]; then printf '\xf3\xb0\xa4\xa2'; else printf '\xf3\xb0\xa4\x9f'; fi; }
{ printf 'ssid\t%s\t%s\t\nip\t%s\t%s\t\nrouter\t%s\t%s\t\n' "${SSID:-—}" "$TEXT" "${IP:-—}" "$TEXT" "$(ipconfig getoption $IF router 2>/dev/null || echo —)" "$TEXT"   # router also in the value color (--text) — a value like ip
  printf '_\tNETWORKS\t%s\t\n' "$TEXT3"
  k=0
  if [ "$SCST" = denied ]; then k=1; printf '_\tLocation access needed ↗\t%s\topen "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"\n' "$TEXT3"
  elif [ -z "$NETS" ] && [ -f "$BUSY" ]; then k=1; printf '_\tScanning …\t%s\t\n' "$TEXT3"
  elif [ -z "$NETS" ]; then k=1; printf '_\tNo saved networks nearby\t%s\t\n' "$TEXT3"
  else while IFS=$'\t' read -r n r; do [ -z "$n" ] && continue; k=$((k + 1))
    if [ -n "$SSID" ] && [ "$n" = "$SSID" ]; then printf '%s\t%s\t%s\t\n' "$(glyph "$r")" "$n" "$TEXT"   # the ✓ is added below as an image (right padding exactly 12)
    else printf '%s\t%s\t%s\t@CONFIG_DIR=%q bash %q %d %q\n' "$(glyph "$r")" "$n" "$TEXT2" "$CONFIG_DIR" "$CONFIG_DIR/plugins/wifi_out.sh" $(( k + 3 )) "$n"; fi
  done <<<"$NETS"; fi
  for ((; k < 4; k++)); do printf '_\t.\t0x00000000\t\n'; done   # network area fixed at 4 rows — empty rows are drawn too (transparent text) so the popup height and the settings row position are the same in all three states: scanning, results, none
  printf 'open\tWi-Fi Settings ↗\t%s\t%s\n' "$TEXT2" "open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"
} | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | POPUP_W=$W popup_rows wifi WI-FI
# left cell: text rows (ssid·ip·router·settings) are drawn 1pt high by the popup, so lowered 1pt · network rows use Nerd Font glyphs (left padding 13 — a glyph is drawn with no left bearing, 1pt left of text)
CUR=$(awk -F'\t' -v s="$SSID" 's!="" && $1==s{print NR}' <<<"$NETS")
# 8 more above the NETWORKS header: row 32, text lowered 4 → +8 above · same below (by request, 10-02). All three states use the same rows, so the height stays fixed
a=(--set wifi.p.0 icon.y_offset=-1 --set wifi.p.1 icon.y_offset=-1 --set wifi.p.2 icon.y_offset=-1 --set wifi.p.3 label.font="$FONT:Regular:11.0" background.height=32 label.y_offset=-4 --set wifi.p.8 icon.y_offset=-1)
for i in 4 5 6 7; do a+=(--set wifi.p.$i icon.font="$NF:Regular:14.0" icon.padding_left=13 icon.color=$([ "$(( i - 3 ))" = "${CUR:-0}" ] && echo $TEXT || echo $TEXT3)); done
a+=(--set wifi.p.3 label="NETWORKS$([ -f "$BUSY" ] && [ -n "$NETS" ] && printf '\302\240\302\240…')")   # while scanning (with the last result still showing) add … to the header
# current network ✓: pushing it with spaces moves in 7.2pt steps, so the right padding wobbles between 11 and 18 → use a text image with its right end at padding 12 (corrected for the 2 margin inside the image and the 1pt-high drawing in popups)
for i in 4 5 6 7; do a+=(--set wifi.p.$i background.image.drawing=off); done
if [ -n "${CUR:-}" ]; then
  CK="$HOME/.cache/sketchybar/st_check.png"; [ -f "$CK" ] || "$CONFIG_DIR/helper/textpng" "✓" "$TEXT" 12 "$CK"
  cw=$(( $(sips -g pixelWidth "$CK" 2>/dev/null | awk '/pixelWidth/{print $2}') / 2 ))
  a+=(--set wifi.p.$(( CUR + 3 )) background.image="$CK" background.image.scale=0.5 background.image.drawing=on background.image.padding_left=$(( W - 12 - cw )) background.image.y_offset=-1)   # ✓ comes from a fallback font, so the margin inside the image is small: 12 (measured)
fi
sketchybar "${a[@]}" 2>/dev/null

# The bar shows the name as is; over 16 characters it becomes 15 + … (the old label.max_chars=10 cut the last letter of an 11-character name). anim_label sizes the cell to the text
SHOW=$(perl -CSA -Mutf8 -e '$_ = shift; print length > 16 ? substr($_, 0, 15) . "…" : $_' "${SSID:-on}")
if [ -n "$IP" ]; then anim_label wifi "$SHOW" label.color=$TEXT
else anim_label wifi "off" label.color=$ERR; fi
