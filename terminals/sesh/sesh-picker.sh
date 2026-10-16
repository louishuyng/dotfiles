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
# shorten_path /a/b/c/d/e  →  d/e   (last 2 segments), into $REPLY
#
# Assigns rather than prints: the callers run it once per zoxide entry, and
# `$(shorten_path ...)` forked a subshell for each of ~250 paths.
#--------------------------------------------------------------------
shorten_path() {
  local p="$1"
  local base="${p##*/}"
  local rest="${p%/*}"
  local parent="${rest##*/}"
  if [[ -z "$parent" || "$parent" == "$rest" ]]; then
    REPLY="$base"
  else
    REPLY="$parent/$base"
  fi
}

#--------------------------------------------------------------------
# build_list <out>
# Each line: "<colored-icon> <display>\t<target>"
#   --with-nth=1 hides the target field, --ansi renders icon color.
#--------------------------------------------------------------------
build_list() {
  local out="$1"
  local windows
  windows=$(tmux list-windows -a -F '#S:#I #W' 2>/dev/null) || return 2
  {
    local line target
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      target="${line%% *}"
      printf '%s%s%s %s\t%s\n' "$ICON_TMUX_FG" "$ICON_TMUX" "$RESET" "$line" "$target"
    done <<< "$windows"

    local path
    while IFS= read -r path; do
      [[ -z "$path" ]] && continue
      shorten_path "$path"
      printf '%s%s%s %s\t%s\n' "$ICON_ZOX_FG" "$ICON_ZOX" "$RESET" "$REPLY" "$path"
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

  local ws_json panes_json tabs_json workspaces cwds tabs
  ws_json=$("$HERDR_BIN" workspace list 2>/dev/null) || return 2
  workspaces=$(printf '%s' "$ws_json" | jq -er '
    .result.workspaces | arrays | map([.workspace_id, .label] | @tsv) | join("\n")' 2>/dev/null) || return 2

  # An in-process set, not a temp file. The dedup below runs once per zoxide
  # entry — ~250 of them — and `grep -qxF` forked for every one to search a
  # handful of open cwds. That single line was 1.7s of a 1.8s popup.
  local -A open_cwds=()

  local ws label cwd
  while IFS=$'\t' read -r ws label; do
    [[ -z "$ws" ]] && continue
    panes_json=$("$HERDR_BIN" pane list --workspace "$ws" 2>/dev/null) || return 2
    cwds=$(printf '%s' "$panes_json" | jq -er '.result.panes | arrays | map(.cwd // empty) | join("\n")' 2>/dev/null) || return 2
    while IFS= read -r cwd; do
      [[ -n "$cwd" ]] && open_cwds["$cwd"]=1
    done <<< "$cwds"

    tabs_json=$("$HERDR_BIN" tab list --workspace "$ws" 2>/dev/null) || return 2
    tabs=$(printf '%s' "$tabs_json" | jq -er --arg ws "$label" --arg ic "$ICON_TMUX_FG$ICON_TMUX$RESET" '
      .result.tabs | arrays | map("\($ic) \($ws):\(.number) \(.label)\t\(.tab_id)") | join("\n")' 2>/dev/null) || return 2
    [[ -z "$tabs" ]] || printf '%s\n' "$tabs" >> "$out"
  done <<< "$workspaces"

  local path
  {
    while IFS= read -r path; do
      [[ -z "$path" ]] && continue
      [[ -n "${open_cwds[$path]-}" ]] && continue
      shorten_path "$path"
      printf '%s%s%s %s\t%s\n' "$ICON_ZOX_FG" "$ICON_ZOX" "$RESET" "$REPLY" "$path"
    done < <(zoxide query -l 2>/dev/null)
  } >> "$out"
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
  local existing windows sessions
  sessions=$(tmux list-sessions -F '#S' 2>/dev/null) || return 2
  if ! grep -qxF -- "$session" <<< "$sessions"; then
    tmux new-session -d -s "$session" -c "$path" || return 2
  else
    windows=$(tmux list-windows -t "$session" -F '#{window_index} #{pane_current_path}' 2>/dev/null) || return 2
    existing=$(awk -v p="$path" 'substr($0, index($0, " ")+1) == p {print $1; exit}' <<< "$windows")
    if [[ -n "$existing" ]]; then
      tmux switch-client -t "$session:$existing"
      return $?
    fi
    tmux new-window -t "$session" -c "$path" || return 2
  fi
  tmux switch-client -t "$session"
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
      return $?
      ;;
  esac

  local expanded="${target/#\~/$HOME}"

  local name root
  while IFS=$'\t' read -r name root; do
    [[ -z "$name" || -z "$root" ]] && continue

    if hd_active; then
      if [[ "$expanded" == "$root" || "$expanded" == "$root/"* ]]; then
        hd_open_project "$name" "$expanded" >/dev/null
        return $?
      fi
      continue
    fi

    if [[ "$expanded" == "$root" ]]; then
      sesh connect "$name"
      return $?
    fi
    if [[ "$expanded" == "$root/"* ]]; then
      open_in_session "$name" "$expanded"
      return $?
    fi
  done < "$roots_tsv"

  # Under no known root: a standalone workspace of its own. Labelled by
  # folder name, or herdr would default the sidebar entry to a bare number.
  if hd_active; then
    hd_open_project "$(basename -- "$expanded")" "$expanded" >/dev/null
    return $?
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
  local label="${2:-$target}" answer status
  if answer=$(printf 'Cancel\nClose\n' | FZF_DEFAULT_OPTS= fzf \
    --no-sort --layout=reverse --prompt 'Confirm > ' \
    --header "Close tab: $label? Running work may stop." \
    --bind 'esc:abort' --no-multi); then
    [[ "$answer" == "Close" ]] || return 0
  else
    status=$?
    (( status == 1 || status == 130 )) && return 0
    return "$status"
  fi
  if hd_active; then
    "$HERDR_BIN" tab close "$target" >/dev/null 2>&1
  else
    tmux kill-window -t "$target" 2>/dev/null
  fi
  return $?
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
  local status=0
  route_selection $'\t'"$target" "$tmp" || status=$?
  rm -f "$tmp"
  return "$status"
}

cmd_main() {
  local tmp
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/sesh-picker.XXXXXX") || return 1
  local cleanup
  printf -v cleanup 'rm -rf -- %q' "$tmp"
  trap "$cleanup" EXIT

  parse_roots "$tmp/roots.tsv"
  local selected key row target label error="" status=0 fzf_status
  local header=$'Enter open/focus · Tab move · Ctrl+D close tab · Esc cancel\nCtrl+R retry list · Ctrl+P preview'
  local preview_cmd
  printf -v preview_cmd 'bash %q --preview {2}' "$SCRIPT"
  while :; do
    if ! cmd_rebuild "$tmp/all.list"; then
      : > "$tmp/all.list"
      error="Could not list projects. Ctrl+R retry · Esc cancel"
      status=2
    fi
    selected=$(FZF_DEFAULT_OPTS= fzf \
      --ansi --no-sort --border none --padding 0 --margin 0 --info=hidden \
      --pointer '▌' --marker '▍' --prompt 'Projects > ' \
      --header "${error:+$error$'\n'}$header" \
      --delimiter=$'\t' --with-nth=1 --nth=1 \
      --expect enter,ctrl-d,ctrl-r \
      --bind 'tab:down,btab:up,ctrl-p:toggle-preview,esc:abort' \
      --with-shell 'bash -c' --preview "$preview_cmd" \
      --preview-window 'right:45%:wrap:border-left' \
      --bind 'start,resize:transform:if [ "$FZF_COLUMNS" -lt 100 ]; then echo "change-preview-window(right:45%:wrap:border-left:hidden)"; else echo "change-preview-window(right:45%:wrap:border-left)"; fi' \
      < "$tmp/all.list")
    fzf_status=$?
    if (( fzf_status != 0 )); then
      (( fzf_status == 1 || fzf_status == 130 )) && return "$status"
      printf 'Could not run project picker.\n' >&2
      return "$fzf_status"
    fi
    key="${selected%%$'\n'*}"
    row="${selected#*$'\n'}"
    [[ "$key" == ctrl-r ]] && { error=""; continue; }
    [[ "$row" == *$'\t'* ]] || continue
    target="${row#*$'\t'}"
    label="${row%%$'\t'*}"
    if [[ "$key" == ctrl-d ]]; then
      if cmd_close "$target" "$label"; then
        error=""
      else
        status=$?
        error="Could not close tab. Ctrl+D retry · Esc cancel"
      fi
    elif route_selection "$row" "$tmp/roots.tsv" >/dev/null 2>&1; then
      return 0
    else
      status=$?
      error="Could not open/focus project. Enter retry · Esc cancel"
    fi
  done
}

case "${1:-}" in
  --preview) shift; cmd_preview "${1:-}" ;;
  --rebuild) shift; cmd_rebuild "${1:-/dev/null}" ;;
  --close)   shift; cmd_close "${1:-}" "${2:-${1:-}}" ;;
  --route)   shift; cmd_route "${1:-}" ;;
  --list)    shift; tmp=$(mktemp) || exit 2
    status=0
    cmd_rebuild "$tmp" || status=$?
    if (( status == 0 )); then cat "$tmp"; else printf 'Could not list projects.\n' >&2; fi
    rm -f "$tmp"
    exit "$status" ;;
  *)         cmd_main ;;
esac
