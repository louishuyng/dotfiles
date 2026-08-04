#!/opt/homebrew/bin/bash

SCRIPT="$(realpath "$0")"
source "$(dirname "$SCRIPT")/roots.sh"
source "$(dirname "$SCRIPT")/../herdr/lib.sh"

# Use ANSI named colors so the terminal palette drives light/dark theming.
ICON_TMUX_FG=$'\033[36m'  # terminal cyan
ICON_ZOX_FG=$'\033[33m'   # terminal yellow
RESET=$'\033[0m'
ICON_TMUX=$''  # nerd-font terminal
ICON_ZOX=$''   # nerd-font lightning bolt

#--------------------------------------------------------------------
# shorten_path /a/b/c/d/e  →  d/e   (last 2 segments)
#--------------------------------------------------------------------
shorten_path() {
  local p="$1"
  local base="${p##*/}"
  local rest="${p%/*}"
  local parent="${rest##*/}"
  if [[ -z "$parent" || "$parent" == "$rest" ]]; then
    printf '%s' "$base"
  else
    printf '%s/%s' "$parent" "$base"
  fi
}

#--------------------------------------------------------------------
# build_list <out>
# Each line: "<colored-icon> <display>\t<target>"
#   --with-nth=1 hides the target field, --ansi renders icon color.
#--------------------------------------------------------------------
build_list() {
  local out="$1"
  {
    local line target
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      target="${line%% *}"
      printf '%s%s%s %s\t%s\n' "$ICON_TMUX_FG" "$ICON_TMUX" "$RESET" "$line" "$target"
    done < <(tmux list-windows -a -F '#S:#I #W' 2>/dev/null)

    local path short
    while IFS= read -r path; do
      [[ -z "$path" ]] && continue
      short=$(shorten_path "$path")
      printf '%s%s%s %s\t%s\n' "$ICON_ZOX_FG" "$ICON_ZOX" "$RESET" "$short" "$path"
    done < <(zoxide query -l 2>/dev/null)
  } > "$out"
}

#--------------------------------------------------------------------
# hd_build_list <out>
#   herdr equivalent of build_list. Open tabs first (cyan terminal glyph,
#   routed by tab id), then zoxide paths not already open (yellow bolt,
#   routed by path). Dedup is by pane cwd, so a project appears once.
#--------------------------------------------------------------------
hd_build_list() {
  local out="$1"
  : > "$out"

  local ws_json panes_json open_cwds
  ws_json=$("$HERDR_BIN" workspace list 2>/dev/null)
  open_cwds="$(mktemp)"

  local ws label
  while IFS=$'\t' read -r ws label; do
    [[ -z "$ws" ]] && continue
    panes_json=$("$HERDR_BIN" pane list --workspace "$ws" 2>/dev/null)
    printf '%s\n' "$panes_json" | jq -r '.result.panes[]?.cwd' >> "$open_cwds"

    "$HERDR_BIN" tab list --workspace "$ws" 2>/dev/null \
      | jq -r --arg ws "$label" --arg ic "$ICON_TMUX_FG$ICON_TMUX$RESET" \
          '.result.tabs[]? | "\($ic) \($ws):\(.number) \(.label)\t\(.tab_id)"' >> "$out"
  done < <(printf '%s\n' "$ws_json" \
             | jq -r '.result.workspaces[]? | "\(.workspace_id)\t\(.label)"')

  local path short
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    grep -qxF "$path" "$open_cwds" && continue
    short=$(shorten_path "$path")
    printf '%s%s%s %s\t%s\n' "$ICON_ZOX_FG" "$ICON_ZOX" "$RESET" "$short" "$path" >> "$out"
  done < <(zoxide query -l 2>/dev/null)

  rm -f "$open_cwds"
}

#--------------------------------------------------------------------
# cmd_preview <target>
#--------------------------------------------------------------------
cmd_preview() {
  local target="${1:-}"
  [[ -z "$target" ]] && return 0

  case "$target" in
    /*|~*)
      local expanded="${target/#\~/$HOME}"
      if command -v eza >/dev/null 2>&1; then
        eza --tree --level=2 --color=always --icons --git-ignore "$expanded" 2>/dev/null \
          || printf '(path not found)\n'
      else
        ls -la "$expanded" 2>/dev/null || printf '(path not found)\n'
      fi
      ;;
    *)
      if hd_active; then
        local pane
        pane=$(hd_first_pane_id "$target")
        [[ -z "$pane" ]] && { printf '(no pane)\n'; return 0; }
        "$HERDR_BIN" pane read "$pane" --source recent-unwrapped --lines 20 \
          || printf '(no output)\n'
      else
        tmux capture-pane -t "$target" -p -E - 2>/dev/null | tail -20 \
          || printf '(no window)\n'
      fi
      ;;
  esac
}

#--------------------------------------------------------------------
open_in_session() {
  local session="$1" path="$2"
  local existing
  existing=$(tmux list-windows -t "$session" -F '#{window_index} #{pane_current_path}' 2>/dev/null \
    | awk -v p="$path" '$2 == p {print $1; exit}')

  if [[ -n "$existing" ]]; then
    tmux switch-client -t "$session:$existing"
  else
    tmux new-window -t "$session" -c "$path" 2>/dev/null \
      || tmux new-session -d -s "$session" -c "$path"
    tmux switch-client -t "$session"
  fi
}

#--------------------------------------------------------------------
# route_selection <selected> <roots_tsv>
# selected = "<display>\t<target>"; routing uses the target field.
#--------------------------------------------------------------------
route_selection() {
  local selected="$1" roots_tsv="$2"
  [[ -z "$selected" ]] && return 0

  local target="${selected#*$'\t'}"

  case "$target" in
    /*|~*) ;;
    *)
      if hd_active; then
        "$HERDR_BIN" tab focus "$target" >/dev/null 2>&1
      else
        tmux switch-client -t "$target"
      fi
      return 0
      ;;
  esac

  local expanded="${target/#\~/$HOME}"

  local name root
  while IFS=$'\t' read -r name root; do
    [[ -z "$name" || -z "$root" ]] && continue

    if hd_active; then
      if [[ "$expanded" == "$root" || "$expanded" == "$root/"* ]]; then
        hd_open_project "$name" "$expanded" >/dev/null
        return 0
      fi
      continue
    fi

    if [[ "$expanded" == "$root" ]]; then
      sesh connect "$name"
      return 0
    fi
    if [[ "$expanded" == "$root/"* ]]; then
      open_in_session "$name" "$expanded"
      return 0
    fi
  done < "$roots_tsv"

  # Under no known root: a standalone workspace of its own. Labelled by
  # folder name, or herdr would default the sidebar entry to a bare number.
  if hd_active; then
    "$HERDR_BIN" workspace create --label "$(basename -- "$expanded")" --cwd "$expanded" --focus >/dev/null 2>&1
    return 0
  fi
  sesh connect "$target"
}

# cmd_close <target> — close a tab (herdr) or window (tmux).
cmd_close() {
  local target="${1:-}"
  [[ -z "$target" ]] && return 0
  case "$target" in
    /*|~*) return 0 ;;  # not open; nothing to close
  esac
  if hd_active; then
    "$HERDR_BIN" tab close "$target" >/dev/null 2>&1
  else
    tmux kill-window -t "$target" 2>/dev/null
  fi
  return 0
}

cmd_rebuild() {
  if hd_active; then
    hd_build_list "${1:-/dev/null}"
  else
    build_list "${1:-/dev/null}"
  fi
}

# cmd_route <target> — route_selection's herdr/tmux dispatch, callable
# without fzf so tests can exercise it directly.
cmd_route() {
  local target="${1:-}"
  local tmp
  tmp=$(mktemp) || return 1
  parse_roots "$tmp"
  route_selection $'\t'"$target" "$tmp"
  rm -f "$tmp"
}

cmd_main() {
  local tmp
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/sesh-picker.XXXXXX") || return 1
  trap 'rm -rf "$tmp"' EXIT

  parse_roots "$tmp/roots.tsv"
  if hd_active; then
    hd_build_list "$tmp/all.list"
  else
    build_list "$tmp/all.list"
  fi

  local selected
  selected=$(FZF_DEFAULT_OPTS= fzf \
    --ansi --no-sort --border none --padding 0 --margin 0 --info=hidden \
    --pointer '▌' --marker '▍' \
    --prompt '❯ ' \
    --delimiter=$'\t' --with-nth=1 --nth=1 \
    --bind 'tab:down,btab:up' \
    --bind "ctrl-d:execute-silent(bash $SCRIPT --close {2}; bash $SCRIPT --rebuild $tmp/all.list)+reload(cat $tmp/all.list)" \
    --preview "bash $SCRIPT --preview {2}" \
    --preview-window 'right:45%:wrap:border-left' \
    < "$tmp/all.list")

  [[ -z "$selected" ]] && exit 0
  route_selection "$selected" "$tmp/roots.tsv"
}

case "${1:-}" in
  --preview) shift; cmd_preview "${1:-}" ;;
  --rebuild) shift; cmd_rebuild "${1:-/dev/null}" ;;
  --close)   shift; cmd_close "${1:-}" ;;
  --route)   shift; cmd_route "${1:-}" ;;
  --list)    shift; tmp=$(mktemp); cmd_rebuild "$tmp"; cat "$tmp"; rm -f "$tmp" ;;
  *)         cmd_main ;;
esac
