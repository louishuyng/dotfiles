#! /bin/bash
set -eo pipefail

if [ "${TERM_PROGRAM:-}" != tern ]; then
  clear
  exec nvim
fi

: "${TERN_PANE:?Ctrl-N requires a Tern pane}"

blocks=$(tern ls --json | jq -ec --arg pane "$TERN_PANE" '
  first(.sessions[].tabs[] | select(any(.blocks[]; (.id | tostring) == $pane)))
  | [.blocks[] | select(.live and .exited == null)]
')
# The launch command identifies Neovim even while the shell is still starting.
editor=$(printf '%s' "$blocks" | jq -r '
  first(.[] | select(.command == "exec nvim" or .command == "nvim") | .id) // empty
')
if [ -n "$editor" ]; then
  exec tern focus "$editor"
fi
panes=$(printf '%s' "$blocks" | jq -r '.[].id')

for pane in $panes; do
  process=$(tern process "$pane" --json)
  if printf '%s' "$process" | jq -e '
    [.child, .foreground] | any(. != null and
      (.name == "nvim" or ((.argv[0] // "" | split("/") | last) == "nvim")))
  ' >/dev/null; then
    exec tern focus "$pane"
  else
    status=$?
    [ "$status" -eq 1 ] || exit "$status"
  fi
done

pane=$(tern split "$TERN_PANE" right --cwd "$PWD" -- exec nvim)
exec tern focus "$pane"
