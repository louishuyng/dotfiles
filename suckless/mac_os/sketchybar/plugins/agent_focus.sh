#!/bin/bash
# AGENTS popup row click: bring Ghostty forward and move the most recently active tmux client to the agent's pane.
# Usage: agent_focus.sh <tmux socket> <pane id>   (from ~/.cache/agent-status; both empty when the agent runs outside tmux)
export PATH="/opt/homebrew/bin:$PATH"
SOCK=$1 PANE=$2
open -a Ghostty
[ -n "$PANE" ] || exit 0
T=(tmux); [ -n "$SOCK" ] && T+=(-S "$SOCK")
[ "$("${T[@]}" display -p -t "$PANE" '#{pane_id}' 2>/dev/null)" = "$PANE" ] || exit 0   # closed pane: Ghostty only
CLIENT=$("${T[@]}" list-clients -F '#{client_activity} #{client_name}' 2>/dev/null | sort -rn | awk 'NR == 1 { print $2 }')
[ -n "$CLIENT" ] || exit 0
"${T[@]}" switch-client -c "$CLIENT" -t "$PANE" \; select-window -t "$PANE" \; select-pane -t "$PANE"
