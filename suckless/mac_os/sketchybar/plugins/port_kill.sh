#!/bin/bash
# Ports popup right-click: confirm, then free the port. port_kill.sh <port>
# docker rows stop the container (killing the listening pid would kill OrbStack itself)
PORT="$1"
[[ "$PORT" =~ ^[0-9]+$ ]] || exit 1
WHAT=$(awk -F'\t' -v p="$PORT" '$1==p{print $2; exit}' "$HOME/.cache/sketchybar/ports.all")

case "$WHAT" in
  "OrbStack internal"*) exit 0 ;;
  *" · docker") CTR="${WHAT% · docker}"; ACTION="Stop container" ;;
  *) ACTION="Kill" ;;
esac

BTN=$(osascript -e "button returned of (display dialog \"Port $PORT\" & return & \"$WHAT\" with title \"Kill port\" buttons {\"Cancel\", \"$ACTION\"} default button \"$ACTION\" cancel button \"Cancel\" with icon caution)" 2>/dev/null)
[ "$BTN" = "$ACTION" ] || exit 0

if [ -n "$CTR" ]; then
  "$(command -v docker || echo "$HOME/.orbstack/bin/docker")" stop "$CTR" >/dev/null 2>&1
  rm -f "$HOME/.cache/sketchybar/ports.docker"
else
  lsof -ti "tcp:$PORT" -sTCP:LISTEN | xargs kill 2>/dev/null
fi
sleep 1
sketchybar --update
