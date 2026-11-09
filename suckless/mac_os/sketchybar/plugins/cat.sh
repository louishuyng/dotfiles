#!/bin/bash
# Pixel cat (rev 7) — replaces the cpu·mem bars. 4 frames (16×10pt), speed = cpu: 0.12s at 80% or more, 0.25s at 50~79% (--info image), below that 0.6 (idle) ~ 0.45s. cpu or mem ≥ 80% uses the --warn image
# meters.sh writes cpu·mem to ~/.cache/sketchybar/cat every 5s. Ends when SketchyBar quits
C="$HOME/.cache/sketchybar"; PX="$C/px"
for p in $(pgrep -f '^/bin/bash .*/plugins/cat.sh$'); do [ "$p" = $$ ] || kill "$p" 2>/dev/null; done
k=1
while pgrep -qx sketchybar; do
  read -r CPU MEM < "$C/cat" 2>/dev/null; CPU=${CPU:-0}; MEM=${MEM:-0}
  w=""; [ "$CPU" -ge 50 ] && w=_fast
  { [ "$CPU" -ge 80 ] || [ "$MEM" -ge 80 ]; } && w=_warn
  sketchybar --set cpu background.image="$PX/cc_$k$w.png" 2>/dev/null   # one cat-circle image (grass + cat, rev 8)
  k=$(( k % 4 + 1 ))
  if [ "$CPU" -ge 80 ]; then sleep 0.12; elif [ "$CPU" -ge 50 ]; then sleep 0.25; else sleep "$(awk -v c="$CPU" 'BEGIN{printf "%.2f", 0.6 - c * 0.003}')"; fi   # 0% 0.6s → 50% 0.45s, then a fixed 0.25s so fast reads as its own state
done
