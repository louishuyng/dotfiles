#! /bin/bash
set -euo pipefail

HERDR_BIN="${HERDR_BIN:-herdr}"

workspaces=$("$HERDR_BIN" workspace list)
workspace=$(printf '%s' "$workspaces" | jq -r '[.result.workspaces[] | select(.label == "Projects")][0].workspace_id // empty')

if [[ -z "$workspace" ]]; then
  created=$("$HERDR_BIN" workspace create --cwd "$HOME" --label Projects --no-focus)
  workspace=$(printf '%s' "$created" | jq -er '.result.workspace.workspace_id')
  initial_tab=$(printf '%s' "$created" | jq -er '.result.tab.tab_id')
  "$HERDR_BIN" plugin pane open --plugin herdr-projects --entrypoint board --placement tab --workspace "$workspace" --focus >/dev/null
  panes=$("$HERDR_BIN" pane list --workspace "$workspace")
  board_tab=$(printf '%s' "$panes" | jq -er '[.result.panes[] | select(.label == "Work board")][0].tab_id')
  "$HERDR_BIN" tab rename "$board_tab" board >/dev/null
  "$HERDR_BIN" tab close "$initial_tab" >/dev/null
  "$HERDR_BIN" workspace focus "$workspace" >/dev/null
  "$HERDR_BIN" tab focus "$board_tab" >/dev/null
  exit 0
fi

"$HERDR_BIN" workspace focus "$workspace" >/dev/null
panes=$("$HERDR_BIN" pane list --workspace "$workspace")
board=$(printf '%s' "$panes" | jq -r '[.result.panes[] | select(.label == "Work board")][0].pane_id // empty')
if [[ -n "$board" ]]; then
  "$HERDR_BIN" plugin pane focus "$board" >/dev/null
else
  "$HERDR_BIN" plugin action invoke herdr-projects.open >/dev/null
fi
