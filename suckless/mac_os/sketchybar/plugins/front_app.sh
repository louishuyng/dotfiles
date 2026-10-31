#!/bin/bash
# Front app name. The shared label updater resizes it together with the media island.
case "$SENDER" in   # app name hover: --text-2 → --text (rev 10)
  mouse.entered) source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"; sketchybar --set "$NAME" label.color=$TEXT; exit 0 ;;
  mouse.exited) source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"; sketchybar --set "$NAME" label.color=$TEXT2; exit 0 ;;
esac
[ "$SENDER" = "front_app_switched" ] || exit 0
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
# same source as the label (left_label.sh re-reads the front app, so a queued event can't leave a stale icon)
app=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | perl -ne 'print /^"LSDisplayName"="(.*)"$/ ? $1 : /^"([^\"]+)"/ ? $1 : "" if $. == 1')
# glyph names come from sketchybar-app-font's map (helpers/app_icons.lua)
glyph=$(APP="${app:-$INFO}" perl -ne 'print $1 if /\[\s*\[\[\Q$ENV{APP}\E\]\]\s*\]\s*=\s*"(:[^"]+:)"/' "$CONFIG_DIR/helpers/app_icons.lua" | head -n1)
sketchybar --set "$NAME" icon="${glyph:-:default:}"
case "$INFO" in
  "Visual Studio Code"|"Code") n=code ;;
  "Google Chrome") n=chrome ;;
  *) n=$(tr '[:upper:]' '[:lower:]' <<<"$INFO") ;;
esac
source "$CONFIG_DIR/plugins/left_label.sh"
resize_left_label front_app "$n" front_app.last
