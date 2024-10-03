#!/usr/bin/env fish

set -l grey "0xff7F7F7F"
set -l green "0xff99cc99"

if pgrep -x "OrbStack" >/dev/null
    sketchybar --set $NAME icon.color=$green
else
    sketchybar --set $NAME icon.color=$grey
end
