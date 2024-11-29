#!/usr/bin/env fish

set -l grey "0xff7F7F7F"
set -l purple "0xffD076F6"

if pgrep -x "OrbStack" >/dev/null
    sketchybar --set $NAME icon.color=$purple
else
    sketchybar --set $NAME icon.color=$grey
end
