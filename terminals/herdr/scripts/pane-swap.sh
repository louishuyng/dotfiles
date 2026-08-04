#!/opt/homebrew/bin/bash
# Swap the focused pane with the previous or next pane in its tab — herdr's
# equivalent of tmux's `{` (swap-pane -U) and `}` (swap-pane -D).
#
# herdr's own `pane swap --direction` is spatial (left/right/up/down); this is
# ordinal, matching tmux. Pane order comes from `pane list`, which returns panes
# in visual order (verified).
#
# Usage: pane-swap.sh <prev|next> [--dry-run]
#   --dry-run prints "<source_pane> <target_pane>" instead of swapping, so the
#   ordinal arithmetic is testable without a running server.

HERDR_BIN="${HERDR_BIN:-herdr}"

direction="$1"
dry_run=0
[[ "$2" == "--dry-run" ]] && dry_run=1

if [[ "$direction" != "prev" && "$direction" != "next" ]]; then
  echo "pane-swap: usage: pane-swap.sh <prev|next> [--dry-run]" >&2
  exit 2
fi

json=$("$HERDR_BIN" pane list 2>/dev/null) || exit 2

focused=$(printf '%s' "$json" | jq -r '.result.panes[]? | select(.focused == true) | .pane_id' 2>/dev/null) || exit 2
[[ -z "$focused" ]] && exit 2

focused_tab=$(printf '%s' "$json" | jq -r '.result.panes[]? | select(.focused == true) | .tab_id' 2>/dev/null) || exit 2
[[ -z "$focused_tab" ]] && exit 2

# `pane list` spans tabs and workspaces, so ordinal position must come from
# the focused pane's own tab, not raw list position.
tab_panes=$(printf '%s' "$json" | jq -c --arg t "$focused_tab" '[.result.panes[]? | select(.tab_id == $t)]' 2>/dev/null) || exit 2
n=$(printf '%s' "$tab_panes" | jq 'length' 2>/dev/null) || exit 2
p=$(printf '%s' "$tab_panes" | jq --arg id "$focused" 'map(.pane_id) | index($id)' 2>/dev/null) || exit 2
[[ -z "$p" || "$p" == "null" ]] && exit 2

target_index=""
if [[ "$direction" == "next" ]]; then
  (( p + 1 < n )) && target_index=$(( p + 1 ))
else
  (( p > 0 )) && target_index=$(( p - 1 ))
fi

# At an edge there's nowhere to swap — no-op rather than erroring, matching
# how `pane swap --direction` no-ops at an edge.
[[ -z "$target_index" ]] && exit 0

target=$(printf '%s' "$tab_panes" | jq -r --argjson i "$target_index" '.[$i].pane_id' 2>/dev/null) || exit 2
[[ -z "$target" || "$target" == "null" ]] && exit 2

if [[ "$dry_run" -eq 1 ]]; then
  echo "$focused $target"
  exit 0
fi

"$HERDR_BIN" pane swap --source-pane "$focused" --target-pane "$target" >/dev/null 2>&1 || exit 2
exit 0
