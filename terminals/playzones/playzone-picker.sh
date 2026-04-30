#!/opt/homebrew/bin/bash
# Playzone picker. Reads playzones.toml from this directory, lets the
# user choose one via fzf, and execs the selected script.

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
TOML="$DIR/playzones.toml"

# Tokyo Night palette + nerd-font icon (matches sesh-picker.sh).
ICON_FG=$'\033[38;2;125;207;255m'   # #7dcfff cyan
RESET=$'\033[0m'
ICON=$''                          # nerd-font glyph (gamepad-ish)

#--------------------------------------------------------------------
# parse_toml <out>
#   Walk playzones.toml. For each [[playzone]] block, emit a single
#   tab-separated line: "<name>\t<description>\t<script-abs-path>".
#--------------------------------------------------------------------
parse_toml() {
  local out="$1"
  : > "$out"
  [[ -r "$TOML" ]] || return 0

  local name="" desc="" script="" line abs
  local in_block=0

  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*\[\[playzone\]\][[:space:]]*$ ]]; then
      if [[ $in_block -eq 1 && -n "$name" && -n "$script" ]]; then
        name="${name//$'\t'/ }"
        desc="${desc//$'\t'/ }"
        script="${script//$'\t'/ }"
        abs="$script"; [[ "$abs" != /* ]] && abs="$DIR/$abs"
        printf '%s\t%s\t%s\n' "$name" "$desc" "$abs" >> "$out"
      fi
      name=""; desc=""; script=""
      in_block=1
      continue
    fi
    [[ $in_block -eq 1 ]] || continue
    if [[ "$line" =~ ^[[:space:]]*name[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*description[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      desc="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*script[[:space:]]*=[[:space:]]*\"(.+)\"[[:space:]]*$ ]]; then
      script="${BASH_REMATCH[1]}"
    fi
  done < "$TOML"

  if [[ $in_block -eq 1 && -n "$name" && -n "$script" ]]; then
    name="${name//$'\t'/ }"
    desc="${desc//$'\t'/ }"
    script="${script//$'\t'/ }"
    abs="$script"; [[ "$abs" != /* ]] && abs="$DIR/$abs"
    printf '%s\t%s\t%s\n' "$name" "$desc" "$abs" >> "$out"
  fi
  return 0
}

#--------------------------------------------------------------------
# render <toml-rows> <out>
#   Convert parsed rows to fzf input:
#     col1: "<icon> <name>"  (display)
#     col2: "<description>"  (display)
#     col3: "<script-abs-path>" (hidden, used for routing)
#--------------------------------------------------------------------
render() {
  local in="$1" out="$2"
  : > "$out"
  local name desc script
  while IFS=$'\t' read -r name desc script; do
    [[ -z "$name" ]] && continue
    printf '%s%s%s %s\t%s\t%s\n' "$ICON_FG" "$ICON" "$RESET" "$name" "$desc" "$script" >> "$out"
  done < "$in"
}

#--------------------------------------------------------------------
# preview <script-path>
#--------------------------------------------------------------------
cmd_preview() {
  local script="${1:-}"
  [[ -z "$script" || ! -r "$script" ]] && { printf '(no preview)\n'; return 0; }
  if command -v bat >/dev/null 2>&1; then
    bat --color=always --style=plain --paging=never "$script"
  else
    cat "$script"
  fi
}

#--------------------------------------------------------------------
cmd_main() {
  local tmp
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/playzone-picker.XXXXXX") || return 1
  trap 'rm -rf "$tmp"' EXIT

  parse_toml "$tmp/rows.tsv"
  render "$tmp/rows.tsv" "$tmp/list.tsv"

  if [[ ! -s "$tmp/list.tsv" ]]; then
    printf '(no playzones configured — edit %s)\n' "$TOML"
    sleep 2
    exit 0
  fi

  local selected
  local script="$0"
  selected=$(FZF_DEFAULT_OPTS= fzf \
    --ansi --no-sort --border none --padding 0 --margin 0 --info=hidden \
    --pointer '▌' --marker '▍' \
    --prompt '❯ ' \
    --delimiter=$'\t' --with-nth=1,2 --nth=1,2 \
    --color='fg:#c0caf5,bg:-1,fg+:#c0caf5,bg+:#364a82,hl:#7aa2f7,hl+:#bb9af7,pointer:#bb9af7,prompt:#7dcfff,marker:#9ece6a,gutter:-1' \
    --bind 'tab:down,btab:up' \
    --preview "bash $script --preview {3}" \
    --preview-window 'right:45%:wrap:border-left' \
    < "$tmp/list.tsv") || exit 0

  [[ -z "$selected" ]] && exit 0

  local script_path
  script_path=$(printf '%s' "$selected" | awk -F'\t' '{print $3}')
  [[ -z "$script_path" || ! -x "$script_path" ]] && {
    echo "playzone-picker: script not executable: $script_path" >&2
    exit 1
  }
  exec "$script_path"
}

case "${1:-}" in
  --preview) shift; cmd_preview "${1:-}" ;;
  *)         cmd_main ;;
esac
