#!/bin/bash
# Settings circle: opens config.sh in an editor in Ghostty. When the editor closes, syntax check → if OK, sketchybar --reload,
# if not, no reload; shows the error and asks whether to reopen. Editor: $EDITOR, else nano (shortcuts shown at the bottom, so easy)
C="$HOME/.config/sketchybar"
[ -d /Applications/Ghostty.app ] || { open -t "$C/config.sh"; exit 0; }   # without Ghostty, the default text editor (reload yourself after saving)
if [ "$1" != run ]; then
  open -na /Applications/Ghostty.app --args --window-width=100 --window-height=36 -e /bin/bash -c "'$C/plugins/edit_config.sh' run"   # passing the path separately makes Ghostty show a 'run this?' dialog
  exit 0
fi
ED="${EDITOR:-nano}"
GP=$(ps -o ppid= -p $PPID | tr -d ' ')   # the Ghostty that opened this window (a separate instance) — closed together when done
bye() { ps -o command= -p "$GP" | grep -q 'ghostty.*edit_config' && kill "$GP"; exit "${1:-0}"; }
while :; do
  "$ED" "$C/config.sh"
  if err=$(bash -n "$C/config.sh" 2>&1 && bash -n "$C/sketchybarrc" 2>&1); then
    sketchybar --reload && echo "saved · sketchybar reloaded" && sleep 1; bye 0
  fi
  printf '\nsyntax error — not reloaded:\n%s\n\nreopen? [Y/n] ' "$err"; read -r a
  [ "$a" = n ] && bye 1
done
