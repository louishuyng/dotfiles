#!/usr/bin/env fish

set -l grey "0xff7F7F7F"
set -l green "0xff99cc99"

if pgrep -x "OrbStack" >/dev/null
   killall OrbStack
   sketchybar --set docker icon.color=$grey label="VM/Off"
   /usr/local/bin/orb stop -a
else
   open -a 'OrbStack'
   sketchybar --set docker icon.color=$green label="VM/On"
   /usr/local/bin/orb start -a
end
