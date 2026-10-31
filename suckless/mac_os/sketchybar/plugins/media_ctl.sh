#!/bin/bash
# Media controls: media_ctl.sh prev | toggle | next. With nothing playing, toggle = resume in the last app
C="$HOME/.cache/sketchybar/media_last"; SRC=$(cut -f7 "$C" 2>/dev/null)
[ -z "$SRC" ] && exit 0   # do nothing when the last-played app is unknown (it used to open Apple Music)
MC=$(command -v media-control || echo /opt/homebrew/bin/media-control)
if [ -x "$MC" ] && [ "$SRC" != music ]; then
  case "$1" in prev) "$MC" previous-track ;; next) "$MC" next-track ;; *) "$MC" toggle-play-pause ;; esac
else
  case "$1" in prev) a="previous track" ;; next) a="next track" ;; *) a="playpause" ;; esac
  osascript -e "tell application \"Music\" to $a" >/dev/null 2>&1
fi
# wait until the state actually changes, then refresh the island (with a fixed 0.4 s wait a slow app left the button at ▶)
D="${BASH_SOURCE[0]%/*}"; before=$("$D/media_src.sh" | cut -f1,3)
for i in 1 2 3 4 5 6 7 8 9 10; do sleep 0.2; [ "$("$D/media_src.sh" | cut -f1,3)" != "$before" ] && break; done
SENDER=media_update NAME=media CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}" bash "$D/media.sh"   # passing on the click environment's SENDER (a mouse event) would make media.sh stop at its hover handling
