#!/opt/homebrew/bin/bash
# Project picker for Rex (prefix s), the same routing as terminals/sesh/sesh-picker.sh and
# the herdr-app sessions mod: open tabs first, then zoxide folders not already open. A
# folder opens in the session named after its sesh.toml root, else after its own folder
# name; a tab already in that folder is reused.
#
# Switching the app to another session is session.select, which the app takes from the
# CLI only with Remote Control on (Settings > Rex Server).
set -uo pipefail

REX="/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
source "$HOME/.dotfiles/terminals/sesh/roots.sh"

TAB_ICON=$'\033[36m\033[0m'
DIR_ICON=$'\033[33m\033[0m'
DIM=$'\033[2m'
RESET=$'\033[0m'

finish() {
  [[ -z "$1" ]] && return
  # The app keeps its own tab per session, so a server-side focus alone doesn't move its
  # view, even within the current session. More than one app client can be connected
  # (e.g. a stray `Rex --help`), so tell each one.
  [[ -n "${2:-}" ]] && "$REX" focus -s "$1" "$2" >/dev/null
  local client
  for client in $("$REX" client ls --json | jq -r '.clients[] | select(.info.kind == "app") | .client_id'); do
    "$REX" -C "$client" do session.select session_id="$1" ${2:+window_id="$2"} >/dev/null
  done
}

# Sessions, tabs and pane cwds come from one `rex do picker-data.lua`; a CLI call per
# session and per pane took most of the picker's startup.
# Rows as the herdr sessions mod draws them: "Space:2 name" for tabs (no name while it is
# still Rex's default "Window xxxxxxxx"), then the last two path segments with the full
# path dimmed. Fields after the first tab are hidden routing data.
build_list() {
  local data=$1 blocks=$2
  jq -r --arg icon "$TAB_ICON" '.tabs[]?
    | (.label | if test("^Window [0-9a-f]{8}$") then "" else " " + . end) as $name
    | "\($icon) \(.session):\(.index)\($name)\(if .active and .session_id == env.REX_SESSION then "  current" else "" end)\ttab\t\(.session_id)\t\(.window_id)"' "$data"

  local -A open=()
  local cwd
  while IFS=$'\t' read -r _ _ cwd; do [[ -n "$cwd" ]] && open[$cwd]=1; done < "$blocks"
  local path parent short
  while IFS= read -r path; do
    [[ -z "$path" || -n "${open[$path]:-}" ]] && continue
    parent=${path%/*}
    short=${parent##*/}/${path##*/}
    printf '%s %s  %s%s%s\tdir\t%s\n' "$DIR_ICON" "${short#/}" "$DIM" "${path/#"$HOME"/\~}" "$RESET" "$path"
  done < <(zoxide query -l 2>/dev/null)
}

open_dir() {
  local path=$1 blocks=$2 roots name s w
  roots=$(mktemp)
  parse_roots "$roots"
  name=$(awk -F'\t' -v p="$path" '$2 == p || index(p, $2 "/") == 1 {print $1; exit}' "$roots")
  rm -f "$roots"
  [[ -z "$name" ]] && name=$(basename "$path")

  s=$("$REX" ls --json | jq -r --arg n "$name" '[.sessions[] | select(.label == $n)][0].session_id // empty')
  if [[ -z "$s" ]]; then
    read -r s w < <("$REX" new "$name" -c "$path" --window "$(basename "$path")" --json |
      jq -r '[.session_id, .initial_windows[0].window_id] | @tsv')
  else
    w=$(awk -F'\t' -v s="$s" -v p="$path" '$1 == s && $3 == p {print $2; exit}' "$blocks")
    [[ -z "$w" ]] && w=$("$REX" window new -s "$s" "$(basename "$path")" -c "$path" --json | jq -r '.window_id')
  fi
  finish "$s" "$w"
}

main() {
  local tmp row kind a b
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  "$REX" do "$(dirname "$0")/picker-data.lua" > "$tmp/data"
  jq -r '.blocks[]? | [.session_id, .window_id, .cwd] | @tsv' "$tmp/data" > "$tmp/blocks"
  if ! row=$(build_list "$tmp/data" "$tmp/blocks" | FZF_DEFAULT_OPTS= fzf --ansi --layout=reverse --no-sort --delimiter=$'\t' --with-nth=1 \
    --prompt '> ' --header 'PROJECTS · Enter open · Ctrl-J/K move · Esc cancel' \
    --bind 'ctrl-j:down,ctrl-k:up'); then
    finish ""
    return 0
  fi
  IFS=$'\t' read -r _ kind a b <<< "$row"
  if [[ "$kind" == tab ]]; then
    finish "$a" "$b"
  else
    open_dir "$a" "$tmp/blocks"
  fi
}

main "$@"
