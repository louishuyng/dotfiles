#!/opt/homebrew/bin/bash

SCRIPT="$(realpath "$0")"
SESH_TOML="${SESH_TOML:-$HOME/.config/sesh/sesh.toml}"

# Tokyo Night palette
ICON_TMUX_FG=$'\033[38;2;125;207;255m'  # #7dcfff cyan
ICON_ZOX_FG=$'\033[38;2;224;175;104m'   # #e0af68 yellow
RESET=$'\033[0m'
ICON_TMUX=$''  # nerd-font terminal
ICON_ZOX=$''   # nerd-font lightning bolt

#--------------------------------------------------------------------
parse_roots() {
  local out="$1"
  : > "$out"
  [[ -r "$SESH_TOML" ]] || return 0

  local current_name="" line
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*name[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      current_name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*path[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]] && [[ -n "$current_name" ]]; then
      local p="${BASH_REMATCH[1]/#\~/$HOME}"
      printf '%s\t%s\n' "$current_name" "$p" >> "$out"
      current_name=""
    fi
  done < "$SESH_TOML"
}

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
      tmux capture-pane -t "$target" -p -E - 2>/dev/null | tail -20 \
        || printf '(no window)\n'
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
      tmux switch-client -t "$target"
      return 0
      ;;
  esac

  local expanded="${target/#\~/$HOME}"

  local name root
  while IFS=$'\t' read -r name root; do
    [[ -z "$name" || -z "$root" ]] && continue
    if [[ "$expanded" == "$root" ]]; then
      sesh connect "$name"
      return 0
    fi
    if [[ "$expanded" == "$root/"* ]]; then
      open_in_session "$name" "$expanded"
      return 0
    fi
  done < "$roots_tsv"

  sesh connect "$target"
}

cmd_main() {
  local tmp
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/sesh-picker.XXXXXX") || return 1
  trap 'rm -rf "$tmp"' EXIT

  parse_roots "$tmp/roots.tsv"
  build_list "$tmp/all.list"

  local selected
  selected=$(FZF_DEFAULT_OPTS= fzf \
    --ansi --no-sort --border none --padding 0 --margin 0 --info=hidden \
    --pointer '▌' --marker '▍' \
    --prompt '❯ ' \
    --delimiter=$'\t' --with-nth=1 --nth=1 \
    --color='fg:#c0caf5,bg:-1,fg+:#c0caf5,bg+:#364a82,hl:#7aa2f7,hl+:#bb9af7,pointer:#bb9af7,prompt:#7dcfff,marker:#9ece6a,gutter:-1' \
    --bind 'tab:down,btab:up' \
    --bind "ctrl-d:execute-silent(tmux kill-window -t {2} 2>/dev/null; bash $SCRIPT --rebuild $tmp/all.list)+reload(cat $tmp/all.list)" \
    --preview "bash $SCRIPT --preview {2}" \
    --preview-window 'right:45%:wrap:border-left' \
    < "$tmp/all.list")

  [[ -z "$selected" ]] && exit 0
  route_selection "$selected" "$tmp/roots.tsv"
}

case "${1:-}" in
  --preview) shift; cmd_preview "${1:-}" ;;
  --rebuild) shift; build_list "${1:-/dev/null}" ;;
  *)         cmd_main ;;
esac
