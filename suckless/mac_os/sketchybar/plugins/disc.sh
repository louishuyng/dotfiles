#!/bin/bash
# Spinning-disc animation — cycles the 8 rotated frames sketchybarrc renders (helper/discpng) while playing. media.sh starts and stops it
PID="$HOME/.cache/sketchybar/disc.pid"
kill "$(cat "$PID" 2>/dev/null)" 2>/dev/null
echo $$ > "$PID"
D="$HOME/.cache/sketchybar/disc/play"; k=0
while :; do
  sketchybar --set media.disc background.image="$D/disc-$k.png" 2>/dev/null || exit 0
  k=$(( (k + 1) % 8 )); sleep 0.2
done
