#!/bin/bash
# Reload once, only when the Mac appearance (dark/light) actually changed.
# Only once even if the same signal arrives several times, or again during a reload.
[ "$SENDER" = "theme_change" ] || exit 0
source "$CONFIG_DIR/config.sh"
[ "$THEME" = "auto" ] || exit 0
NOW=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo Light)
F="$HOME/.cache/sketchybar/theme"
[ "$NOW" = "$(cat "$F" 2>/dev/null)" ] && exit 0
mkdir -p "$(dirname "$F")"; echo "$NOW" > "$F"
sketchybar --reload
