#!/bin/bash
# Popup '+N more · show all': the full list in a terminal (new Ghostty window). show_list.sh <name>  (e.g. ports → ~/.cache/sketchybar/ports.all)
# Passing a file path to Ghostty shows a 'run this file?' dialog, so only the name is passed
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
[ -d /Applications/Ghostty.app ] || [ "$1" = run ] || { open -t "$HOME/.cache/sketchybar/$1.all"; exit 0; }   # without Ghostty, open in the text editor
if [ "$1" != run ]; then open -na /Applications/Ghostty.app --args --window-width=80 --window-height=28 -e /bin/bash -c "'$SELF' run $1"; exit 0; fi   # passing the path separately makes Ghostty show a 'run this?' dialog, hence the -c string
GP=$(ps -o ppid= -p $PPID | tr -d ' ')
F="$HOME/.cache/sketchybar/$2.all"; T=$(tr '[:lower:]' '[:upper:]' <<<"$2")
printf '\n  %s  (%s items)\n\n' "$T" "$(grep -c . "$F")"; awk -F'\t' '{printf "  :%-6s %s\n", $1, $2}' "$F"
printf '\n  press any key to close'; read -rsn1
ps -o command= -p "$GP" | grep -q 'ghostty.*show_list' && kill "$GP"
