#!/usr/bin/env fish

source "$CONFIG_DIR/colors.sh"

if pgrep -x "OrbStack" >/dev/null
   killall OrbStack
   sketchybar --set docker icon.color=$GREY
   /usr/local/bin/orb stop -a
else
   open -a 'OrbStack'
   sketchybar --set docker icon.color=$MAGENTA
   /usr/local/bin/orb start -a
end
