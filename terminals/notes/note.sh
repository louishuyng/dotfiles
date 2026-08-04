#!/opt/homebrew/bin/bash
# One reused scratch note in the Obsidian vault, opened full-window by C-a n.
# Deliberately not a picker and not per-day: a single file you dump anything into.

set -uo pipefail

DIR="$(dirname "$(realpath "$0")")"

# tmux doesn't source fish config, so a server started outside a login shell
# won't have NOTES_DIR — this fallback is what keeps the binding working there.
NOTES_DIR="${NOTES_DIR:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Louis}"
NOTE="$NOTES_DIR/Notes/Inbox/Quick Note.md"

mkdir -p "$(dirname "$NOTE")"
[[ -e "$NOTE" ]] || : > "$NOTE"

# End of file in insert mode, so it's ready to type into. Content persists
# across opens — this is a scratchpad, not a fresh buffer each time.
exec nvim -c "source $DIR/note.vim" -c 'normal! G$' -c 'startinsert!' -- "$NOTE"
