#!/bin/bash
# pilo circle motion - cycles the frames of the current state (px/pilo_<state>_<n>.png). Started by pilo.sh; exits when the state file says off (no Pilo)
# Kept light: only urgent states move fast (0.35~0.45s), the rest 1.2~2s, unbound is a single frame. With Reduce Motion (Accessibility) or PILO_ANIM=0 only the first frame is shown
# While the PILO popup is open the small face on each row moves too: one 0.15s tick drives the circle and the rows in a single command; when it closes only the circle moves
C="$HOME/.cache/sketchybar"; PX="$C/px"; source "$CONFIG_DIR/config.sh" 2>/dev/null
for p in $(pgrep -f '^/bin/bash .*/plugins/pilo_anim.sh$'); do [ "$p" = $$ ] || kill "$p" 2>/dev/null; done
spec() { case "$1" in running) F=4 T=0.45 P=3 ;; blocked) F=2 T=0.4 P=3 ;; failed) F=2 T=0.35 P=2 ;; gaveUp) F=2 T=1.2 P=8 ;; stalled) F=2 T=1.6 P=11 ;; limited) F=2 T=1.2 P=8 ;; idle) F=2 T=2 P=13 ;; *) F=1 T=3 P=20 ;; esac; }   # F frames · T period (s) · P popup ticks (0.15s × P ≈ T)
alive() { pgrep -qx sketchybar || exit 0; }
k=1; last=""; n=0; t=0
while :; do
  read -r S < "$C/pilo" 2>/dev/null; [ "$S" = off ] || [ -z "$S" ] && exit 0
  [ $(( n % 20 )) = 0 ] && RM=$(defaults read com.apple.universalaccess reduceMotion 2>/dev/null || echo 0); n=$((n + 1))
  { [ "$RM" = 1 ] || [ "${PILO_ANIM:-1}" = 0 ]; } && { alive; sleep 3; continue; }   # pilo.sh already drew the first frame
  O=""; read -r O < "$C/popup_open" 2>/dev/null
  if [ "$O" = pilo.ul ]; then   # popup open: on tick t, change only the states whose frame advances, in one command
    t=$((t + 1)); a=(); i=0; [ $(( t % 40 )) = 0 ] && alive
    spec "$S"; [ $F -gt 1 ] && [ $(( t % P )) = 0 ] && a+=(--set pilo background.image="$PX/pilo_${S}_$(( t / P % F + 1 )).png")
    while read -r R; do
      spec "$R"; [ $F -gt 1 ] && [ $(( t % P )) = 0 ] && a+=(--set pilo.ul.p.$i background.image="$PX/pilo_s_${R}_$(( t / P % F + 1 )).png")
      i=$((i + 1))
    done < "$C/pilo_rows" 2>/dev/null
    [ ${#a[@]} -gt 0 ] && sketchybar "${a[@]}" 2>/dev/null
    last=""; sleep 0.15; continue
  fi
  alive
  spec "$S"; [ $F = 1 ] && { sleep 3; continue; }
  [ "$S" = "$last" ] || { k=1; last=$S; }
  k=$(( k % F + 1 ))
  sketchybar --set pilo background.image="$PX/pilo_${S}_$k.png" 2>/dev/null
  sleep $T
done
