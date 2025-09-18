#!/usr/bin/env fish

source "$CONFIG_DIR/colors.sh"

if pgrep -x "OrbStack" >/dev/null
    sketchybar --set $NAME icon.color=$MAGENTA
else
    sketchybar --set $NAME icon.color=$GREY
end
