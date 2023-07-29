#!/usr/bin/env sh

sketchybar --add item svim.mode left \
           --set svim.mode popup.align=left \
                           script="sketchybar --set svim.mode popup.drawing=off" \
           --subscribe svim.mode front_app_switched window_focus \
           --add item svim.cmdline popup.svim.mode \
           --set svim.cmdline icon="Command: "
