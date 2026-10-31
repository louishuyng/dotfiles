#!/bin/bash
# Receives the shell_cwd event (CWD=...) sent by the zsh hook. See README.
source "$CONFIG_DIR/config.sh"
DIR="${CWD:-$(cat "$CWD_FILE" 2>/dev/null)}"
[ -d "$DIR" ] || exit 0
echo "$DIR" > "$CWD_FILE"

sketchybar --set cwd drawing=on label="${DIR/#$HOME/~}"   # left empty, a 12 padding remains and widens the space after the app name, so hidden at first
B=$(git -C "$DIR" branch --show-current 2>/dev/null)
if [ -n "$B" ]; then sketchybar --set git drawing=on label="$B"
else sketchybar --set git drawing=off; fi
