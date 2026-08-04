#!/opt/homebrew/bin/bash
# sesh.toml root parsing, shared by the project picker and the playzone helpers.

SESH_TOML="${SESH_TOML:-$HOME/.config/sesh/sesh.toml}"

# parse_roots <out>
#   Write one "<name>\t<abs-path>" line per [[session]] block to <out>.
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

# sesh_root_for <name>
#   Print the path registered for <name>, or nothing.
sesh_root_for() {
  local name="$1" tmp
  [[ -z "$name" ]] && return 0
  tmp=$(mktemp) || return 1
  parse_roots "$tmp"
  awk -F'\t' -v n="$name" '$1 == n {print $2; exit}' "$tmp"
  rm -f "$tmp"
}
