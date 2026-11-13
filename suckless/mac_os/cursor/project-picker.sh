#!/opt/homebrew/bin/bash
# Project picker for Cursor (ctrl+a s), run as the "Pick project" user task. Rows match
# terminals/rex/scripts/project-picker.sh: zoxide folders, last two segments with the full
# path dimmed. `cursor <dir>` focuses the window that already has the folder open, else
# opens a new one.
set -uo pipefail

CURSOR="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"

DIR_ICON=$'[33m[0m'
DIM=$'\033[2m'
RESET=$'\033[0m'

build_list() {
  local path parent short
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    parent=${path%/*}
    short=${parent##*/}/${path##*/}
    printf '%s %s  %s%s%s\t%s\n' "$DIR_ICON" "${short#/}" "$DIM" "${path/#"$HOME"/\~}" "$RESET" "$path"
  done < <(zoxide query -l 2>/dev/null)
}

row=$(build_list | FZF_DEFAULT_OPTS= fzf --ansi --layout=reverse --no-sort --delimiter=$'\t' --with-nth=1 \
  --prompt '> ' --header 'PROJECTS · Enter open · Ctrl-J/K move · Esc cancel' \
  --bind 'ctrl-j:down,ctrl-k:up') || exit 0
"$CURSOR" "${row##*$'\t'}"
