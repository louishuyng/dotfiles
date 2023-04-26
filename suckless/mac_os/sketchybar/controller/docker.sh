#!/usr/bin/env fish

set -l red "0xffed8796"
set -l green "0xffa6da95"

if /Applications/Docker.app/Contents/Resources/bin/docker info > /dev/null 2>&1
    sketchybar --set $NAME label="on |" label.color=$green
else
    sketchybar --set $NAME label="off |" label.color=$red
end
