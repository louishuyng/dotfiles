#!/usr/bin/env fish

set -l red "0xffcc6666"
set -l green "0xff99cc99"

if pgrep -x "OrbStack" >/dev/null
   killall OrbStack
   sketchybar --set docker icon.color=$red
else
  open -a 'OrbStack'
   sketchybar --set docker icon.color=$green
end
