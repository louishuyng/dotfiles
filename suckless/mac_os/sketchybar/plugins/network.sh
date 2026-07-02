#!/bin/bash

source "$CONFIG_DIR/colors.sh"

IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
CACHE="/tmp/sketchybar-net-${USER}"
INTERVAL=2  # must match items/network.sh update_freq

if [ -z "$IFACE" ]; then
  sketchybar -m --set network label="offline" icon.color=$GREY label.color=$GREY
  exit 0
fi

# First matching line for the interface (Link row has the byte counters)
read -r IN_BYTES OUT_BYTES < <(
  netstat -ibnI "$IFACE" 2>/dev/null \
    | awk -v i="$IFACE" '$1==i {print $7, $10; exit}'
)

if [ -z "$IN_BYTES" ] || [ -z "$OUT_BYTES" ]; then
  sketchybar -m --set network label="--" icon.color=$GREY label.color=$GREY
  exit 0
fi

NOW=$(date +%s)
IN_RATE=0
OUT_RATE=0
if [ -f "$CACHE" ]; then
  read -r PREV_TIME PREV_IN PREV_OUT < "$CACHE"
  DT=$((NOW - PREV_TIME))
  [ "$DT" -lt 1 ] && DT=$INTERVAL
  IN_RATE=$(( (IN_BYTES  - PREV_IN ) / DT ))
  OUT_RATE=$(( (OUT_BYTES - PREV_OUT) / DT ))
  # Guard against counter resets or negatives
  [ "$IN_RATE"  -lt 0 ] && IN_RATE=0
  [ "$OUT_RATE" -lt 0 ] && OUT_RATE=0
fi
printf "%s %s %s\n" "$NOW" "$IN_BYTES" "$OUT_BYTES" >"$CACHE"

humanize() {
  awk -v b="$1" 'BEGIN{
    if      (b >= 1048576) printf("%.1fM", b/1048576)
    else if (b >=    1024) printf("%.0fK", b/1024)
    else                   printf("%dB",   b)
  }'
}

IN_H=$(humanize "$IN_RATE")
OUT_H=$(humanize "$OUT_RATE")

# Pick a color based on the busier direction
PEAK=$IN_RATE
[ "$OUT_RATE" -gt "$PEAK" ] && PEAK=$OUT_RATE
if   [ "$PEAK" -ge 1048576 ]; then COLOR=$GREEN    # ≥ 1 MB/s
elif [ "$PEAK" -ge   10240 ]; then COLOR=$YELLOW   # ≥ 10 KB/s
else                               COLOR=$GREY
fi

sketchybar -m --set network \
  label="↓${IN_H} ↑${OUT_H}" \
  icon.drawing=off \
  label.color=$COLOR
