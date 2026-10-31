#!/bin/bash
# Checks that the bar is really drawn and restarts SketchyBar if not. Called by popup_guard.sh a few seconds after the display setup changes or the Mac wakes
#   Symptom: when the display setup changes during sleep the process stays alive with bar drawing=on, but no item has a window (empty bounding_rects). --reload does not bring it back; a restart does
#   Loop guard: at most one restart per 5 minutes. Log: ~/.cache/sketchybar/health.log
C="$HOME/.cache/sketchybar"; LOG="$C/health.log"; IT="${HEALTH_ITEM:-clock}"
for _ in 1 2 3 4 5; do   # queries sometimes come back empty - only five empty answers in a row count
  sketchybar --query "$IT" 2>/dev/null | grep -q '"origin"' && exit 0
  sleep 1
done
pgrep -qx sketchybar || exit 0   # not running: launchd brings it back
now=$(date +%s); last=$(cat "$C/health.last" 2>/dev/null || echo 0)
[ $(( now - last )) -lt 300 ] && { echo "$(date '+%F %T') no windows, restart skipped (last $(( now - last ))s ago)" >> "$LOG"; exit 0; }
echo $now > "$C/health.last"
LABEL=$(launchctl list 2>/dev/null | awk '/sketchybar/{print $3; exit}')
echo "$(date '+%F %T') no windows after ${SENDER:-check} → restart (${LABEL:-no launchd label})" >> "$LOG"
if [ -n "$SB_RESTART_CMD" ]; then eval "$SB_RESTART_CMD"   # for tests
elif [ -n "$LABEL" ]; then launchctl kickstart -k "gui/$(id -u)/$LABEL"; fi
