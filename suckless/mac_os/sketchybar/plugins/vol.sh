#!/bin/bash
# Volume — right end of the media island [glyph ▮▮▯▯▯]. No number. Popup VOLUME: slider · mute · OUTPUT devices · sound settings
# Value: osascript (get volume settings) · devices: helper/audio (CoreAudio + paired Bluetooth, nothing to install — matches the Control Center sound output list)
# Refresh: volume_change (volume keys, slider — bar and slider only, at once) · every 10 s (device connect/disconnect has no event, so poll) · after wake
# Only the slider (vol_slider.sh) and the mute row change the volume value
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"
P="$CONFIG_DIR/plugins"; NF="JetBrainsMono Nerd Font Propo"; C="$HOME/.cache/sketchybar"
G_LO=$'\xf3\xb0\x95\xbf' G_MID=$'\xf3\xb0\x96\x80' G_HI=$'\xf3\xb0\x95\xbe' G_MUTE=$'\xf3\xb0\x96\x81' G_BT=$'\xf3\xb0\xa5\xb0' G_BTMUTE=$'\xf3\xb0\x9f\x8e' G_LAPTOP=$'\xf3\xb0\x8c\xa2'
bar() { # glyph (built-in and others = 3-level speaker / Bluetooth = headphones, muted = slashed) + 5 cells (20% each, lit cell --text · empty cell --bg) + slider
  local g gc=$TEXT2 n i a
  if [ "$KIND" = bluetooth ]; then g=$G_BT; [ "$M" = true ] && g=$G_BTMUTE
  elif [ "$M" = true ]; then g=$G_MUTE; elif [ "$V" -le 33 ]; then g=$G_LO; elif [ "$V" -le 66 ]; then g=$G_MID; else g=$G_HI; fi
  [ "$M" = true ] && gc=$TEXT3
  n=$(( (V + 19) / 20 )); a=(--set vol icon="$g" icon.color=$gc)
  for i in 1 2 3 4 5; do a+=(--set vol.$i background.color=$([ $i -le $n ] && echo $TEXT || echo $LINE)); done
  # the slider % ends at the right padding 12 (a slider item ignores label.width, so pad the front by the text width)
  local lt="$V%" lc=$TEXT hc=$TEXT lw; [ "$M" = true ] && { lt=off; lc=$TEXT3; hc=$TEXT3; }   # when muted show off (--text-3) instead of %
  lw=$("$HOME/.local/bin/dotbin" sb width "$lt")
  [ -n "$(sketchybar --query vol.slider 2>/dev/null)" ] && a+=(--set vol.slider slider.percentage=$V slider.highlight_color=$hc label="$lt" label.color=$lc label.padding_left=$(( 53 - lw )))
  sketchybar "${a[@]}"
}
# volume only changed (volume keys, slider): bar and slider only, at once. Mute and device use the last values read
if [ "$SENDER" = volume_change ] && [[ "$INFO" =~ ^[0-9]+$ ]]; then
  V=$INFO; IFS=$'\t' read -r M KIND <<<"$(cat "$C/vol_state" 2>/dev/null)"; bar; exit 0
fi
IFS=, read -r V M <<<"$(osascript -e 'set s to get volume settings' -e 'return (output volume of s as text) & "," & (output muted of s as text)' 2>/dev/null)"
V=${V:-0}; DEV=$("$CONFIG_DIR/helper/audio" 2>/dev/null); BT=$("$CONFIG_DIR/helper/audio" bt 2>/dev/null)
KIND=$(awk -F'\t' '$4==1{print $3}' <<<"$DEV"); printf '%s\t%s\n' "$M" "$KIND" > "$C/vol_state"

# The popup items are created here once, in order: padding · title · padding · slider (vol) · 9 rows · padding. --move does not work on popup items, so
# creation order is what puts the slider under the title. The row count (9) is written to the popup.sh cache so popup_rows does not rebuild them
if [ -z "$(sketchybar --query vol.slider 2>/dev/null)" ]; then
  r=(); for it in $(sketchybar --query vol.ul 2>/dev/null | "$HOME/.local/bin/dotbin" sb popup-items 2>/dev/null); do r+=(--remove "$it"); done
  [ ${#r[@]} -gt 0 ] && sketchybar "${r[@]}" >/dev/null 2>&1
  a=(--add item vol.ul.p.a popup.vol.ul --add item vol.ul.p.t popup.vol.ul --add item vol.ul.p.g popup.vol.ul
     --add slider vol.slider popup.vol.ul 132
     --set vol.slider icon=vol icon.font="$FONT:Regular:12.0" icon.color=$TEXT3 icon.width=64 icon.padding_left=12 icon.padding_right=0 \
           label.font="$FONT:Regular:12.0" label.color=$TEXT label.padding_right=12 \
           slider.highlight_color=$TEXT slider.background.color=$LINE slider.background.height=10 slider.background.corner_radius=0 slider.background.y_offset=-1 \
           slider.knob.drawing=off background.drawing=on background.color=0x00000000 background.height=24 script="$P/vol_slider.sh"
     --subscribe vol.slider mouse.clicked)
  for i in 0 1 2 3 4 5 6 7 8; do a+=(--add item vol.ul.p.$i popup.vol.ul); done
  sketchybar "${a[@]}" --add item vol.ul.p.z popup.vol.ul
  echo 9 > "$POPUP_CACHE/popup.vol.ul.n"; rm -f "$POPUP_CACHE/popup.vol.ul"
fi
bar

# popup rows: mute · OUTPUT · devices (max 6, padded with empty rows) · settings. Device row = name + ✓ at the right end (current)
# mute row: the glyph is always the slashed speaker; when muted, glyph --text + 'Unmute' / otherwise glyph --text-3 + 'Mute' (no check mark, per the user's reference)
# device row: the selected device has glyph and name --text + ✓, the others glyph --text-3 · name --text-2
# trailing space on 'Mute ' / 'Unmute ' (→ NBSP): a row with no space is drawn about 1pt higher, so both variants carry one and sit at the same height
W=261; VW=$(( W - 64 - 12 ))   # value cell: from after the left cell 64 (padding 12 included) to the right padding 12
right() { local n s; n=$(printf '.\t%s\n' "$1" | "$HOME/.local/bin/dotbin" sb fit $((VW - 14)) | cut -f2)   # keep room for " ✓"
  s=$(( ((VW - $("$HOME/.local/bin/dotbin" sb width "$n") - 7) * 10 + 36) / 72 )); [ $s -lt 1 ] && s=1; printf '%s%*s✓' "$n" $s ''; }   # rounded
SAY="@$P/vol_out.sh"; MUTE_CMD="@osascript -e \"set volume output muted (not output muted of (get volume settings))\"; SENDER=routine CONFIG_DIR=\"$CONFIG_DIR\" bash \"$P/vol.sh\""
{ printf '%s\t%s\t%s\t%s\n' "$G_MUTE" "$([ "$M" = true ] && echo 'Unmute ' || echo 'Mute ')" "$TEXT" "$MUTE_CMD"
  printf '_\tOUTPUT\t%s\t\n' "$TEXT3"
  k=0; while IFS=$'\t' read -r id name kind cur; do [ -z "$id" ] && continue; k=$((k + 1)); [ $k -gt 6 ] && break
    case "$kind" in builtin) g=$G_LAPTOP ;; bluetooth) g=$G_BT ;; *) g=$G_HI ;; esac
    if [ "$cur" = 1 ]; then printf '%s\t%s\t%s\t\n' "$g" "$(right "$name")" "$TEXT"
    else printf '%s\t%s\t%s\t%s set %s %s\n' "$g" "$name" "$TEXT2" "$SAY" "$id" "$k"; fi
  done <<<"$("$HOME/.local/bin/dotbin" sb fit $VW <<<"$DEV")"   # long names spill past the fixed width
  while IFS=$'\t' read -r addr name; do [ -z "$addr" ] && continue; k=$((k + 1)); [ $k -gt 6 ] && break   # Bluetooth that is only paired — click connects, then switches
    printf '%s\t%s\t%s\t%s connect %s %s\n' "$G_BT" "$name" "$TEXT2" "$SAY" "$addr" "$k"
  done <<<"$("$HOME/.local/bin/dotbin" sb fit $VW <<<"$BT")"
  for ((; k < 6; k++)); do printf '~\t.\t\t\n'; done
  printf 'open\tSound Settings ↗\t%s\topen "x-apple.systempreferences:com.apple.Sound-Settings.extension"\n' "$TEXT2"
} | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | POPUP_W=$W popup_rows vol.ul VOLUME
# glyph rows use the Nerd Font · OUTPUT is an 11pt caption
# settings row: left-cell text (the icon slot) is drawn with its baseline 1pt above the value text (measured on the real popup, key 407-426 vs 409-429px) → lowered 1pt
# icon rows (mute, devices) use left padding 13 — a glyph is drawn with no left bearing, 1~2px left (48px) of text (vol·OUTPUT·key, starting at 49~50px), so pushed 1pt (measured @2x)
a=(--set vol.ul.p.8 icon.y_offset=-1 --set vol.ul.p.0 icon.padding_left=13 icon.font="$NF:Regular:14.0" icon.color=$([ "$M" = true ] && echo $TEXT || echo $TEXT3) --set vol.ul.p.1 label.font="$FONT:Regular:11.0")
CUR=$(awk -F'\t' '$4==1{print NR}' <<<"$DEV")   # row number of the selected device (from 1) → vol.ul.p.(row+1)
# the Bluetooth glyph is smaller than the laptop in the font (ink 11.9×7.0 vs 14.0×9.4pt @14) → enlarged to 17pt to match the height
KINDS=($( { awk -F'\t' '$1!=""{print $3}' <<<"$DEV"; awk -F'\t' '$1!=""{print "bluetooth"}' <<<"$BT"; } | head -6))
for i in 2 3 4 5 6 7; do k=${KINDS[$((i - 2))]}; fs=14.0; yo=0; [ "$k" = bluetooth ] && fs=17.0   # 17pt left as is lines up with the name's center (measured; -1 is 2.5px too low)
  a+=(--set vol.ul.p.$i icon.padding_left=13 icon.font="$NF:Regular:$fs" icon.y_offset=$yo icon.color=$([ "$i" = "$(( ${CUR:-0} + 1 ))" ] && echo $TEXT || echo $TEXT3)); done
sketchybar "${a[@]}" 2>/dev/null
