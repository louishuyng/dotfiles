#!/usr/bin/env fish

set -l red "0xffcc6666"
set -l green "0xff99cc99"

if pgrep -x "OrbStack" >/dev/null
    sketchybar --set $NAME icon.color=$green
else
    sketchybar --set $NAME icon.color=$red
end
