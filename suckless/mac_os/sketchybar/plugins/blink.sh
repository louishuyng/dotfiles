#!/bin/bash
# Wordmark cursor blink — wordmark.css gn-blink: 1.06s period, half on / half off.
# No blinking when Reduce Motion (Accessibility) is on (the spec's prefers-reduced-motion).
# Started anew each time rc is reloaded; the previous one is killed via the pid file.
PID="$HOME/.cache/sketchybar/blink.pid"
kill "$(cat "$PID" 2>/dev/null)" 2>/dev/null
[ "$(defaults read com.apple.universalaccess reduceMotion 2>/dev/null)" = 1 ] && exit 0
echo $$ > "$PID"
while sketchybar --set wordmark.cursor background.drawing=toggle 2>/dev/null; do sleep 0.53; done
