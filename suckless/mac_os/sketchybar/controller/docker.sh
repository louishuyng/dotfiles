#!/usr/bin/env fish

set -l red "0xffed8796"
set -l green "0xffa6da95"

if pgrep -x "OrbStack" >/dev/null
    sketchybar --set $NAME label="running " label.color=$green
else
    sketchybar --set $NAME label="stopped " label.color=$red
end
