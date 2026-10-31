#!/bin/bash
# Pixel cat (cpu·mem, drawn by cat.sh) + bat 5-cell bar. The popup (SYSTEM) shows numbers — refreshed in the background every 5s (rev 7)
source "$CONFIG_DIR/colors.sh"; source "$CONFIG_DIR/config.sh"; source "$CONFIG_DIR/plugins/popup.sh"

CPU=$(ps -A -o %cpu= | awk -v n="$(sysctl -n hw.ncpu)" '{s+=$1} END {printf "%d", s/n}')
MEM=$(memory_pressure | awk '/free percentage/ {printf "%d", 100-$5}')
BATT=$(pmset -g batt); BAT=$(grep -Eo '[0-9]+%' <<<"$BATT" | head -1); BAT=${BAT%\%}
AC=0; grep -q 'AC Power' <<<"$BATT" && AC=1
REMAIN=$(grep -Eo '[0-9]+:[0-9]+ remaining' <<<"$BATT" | cut -d' ' -f1)
TOTAL=$(( $(sysctl -n hw.memsize) / 1073741824 ))
USED=$(awk -v m="$MEM" -v t="$TOTAL" 'BEGIN{printf "%.1f", m*t/100}')
# storage: same numbers as System Settings > General > Storage (APFS container total and free, decimal GB; purgeable space is not counted as free). cached for 60s
DF="$HOME/.cache/sketchybar/disk"
[ -n "$(find "$DF" -mtime -60s 2>/dev/null)" ] || LANG=C diskutil info / | awk -F'[()]' '/Container Total Space/{t=$2+0} /Container Free Space/{f=$2+0}
  END{if (t) printf "%.0f / %.0f GB · %.0f GB free", (t-f)/1e9, t/1e9, f/1e9}' > "$DF"
SSD=$(cat "$DF" 2>/dev/null)

# warning colors (2026.09.30): cpu ≥ 80 → warn, bat ≤ 15 and not on AC → err. Applied to both the bar and the popup values
CC=$TEXT; [ "$CPU" -ge 80 ] && CC=$WARN
MC=$TEXT; [ "$MEM" -ge 80 ] && MC=$WARN   # rev 7: mem ≥ 80 (cat also --warn)
BC=$TEXT; [ "$BAT" -le 20 ] && [ $AC = 0 ] && BC=$ERR   # CHANGES-8: ≤ 20
echo "$CPU $MEM" > "$HOME/.cache/sketchybar/cat"   # cat speed and color (cat.sh)
printf 'cpu\t%s%%\t%s\t\nmem\t%s%%  %s/%sG\t%s\t\nssd\t%s\t%s\t\nopen\tActivity Monitor ↗\t%s\topen -a "Activity Monitor"\n' \
  "$CPU" "$CC" "$MEM" "$USED" "$TOTAL" "$MC" "${SSD:--}" "$TEXT" "$TEXT2" \
  | awk -F'\t' -v OFS='\t' '{ gsub(/ /, "\302\240", $2) } 1' | popup_rows cpu.ul SYSTEM
# the popup draws left-cell text 1pt above the value text → lower by 1pt (same correction as measured for the volume popup)
sketchybar --set cpu.ul.p.0 icon.y_offset=-1 --set cpu.ul.p.1 icon.y_offset=-1 --set cpu.ul.p.2 icon.y_offset=-1 --set cpu.ul.p.3 icon.y_offset=-1 2>/dev/null   # the bat row moved to the BATTERY popup (rev 8)

fill() { # name value warn_color_if
  local n=$(( ($2 + 19) / 20 )) c=$TEXT
  [ -n "$3" ] && c=$3
  for i in 1 2 3 4 5; do
    [ $i -le $n ] && col=$c || col=$LINE
    args+=(--set "$1.$i" background.color=$col)
  done
}
args=()
C=$BC; [ $AC = 1 ] && C=$ACCENT   # on AC power use the theme color (accent, our addition) — low battery (err) only applies off AC, so they never overlap
fill bat "$BAT" "$C"
sketchybar "${args[@]}"
