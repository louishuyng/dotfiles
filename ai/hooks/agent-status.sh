#!/bin/bash
# Shared command hook: records whether a Claude/Codex session is working or idle, for the SketchyBar agent circle.
# Usage: agent-status.sh <working|waiting|idle>   (native hook JSON on stdin; waiting = an approval prompt is open)
# One file per session in ~/.cache/agent-status: agent · state · cwd · pid · epoch · tmux socket · tmux pane (tab separated).
# Never fails the agent: every path exits 0 and prints nothing (Stop hooks parse stdout).
STATE=$1
case "$STATE" in working|waiting|idle) ;; *) exit 0 ;; esac
DIR="$HOME/.cache/agent-status"
IN=$(head -c 65536)
field() { printf '%s' "$IN" | perl -ne 'print $1 and exit if /"'"$1"'"\s*:\s*"((?:[^"\\]|\\.)*)"/'; }
SID=$(field session_id | tr -cd 'A-Za-z0-9_-')
[ -n "$SID" ] || exit 0
CWD=$(field cwd)

# The agent process is the nearest claude/codex ancestor; its pid lets the bar drop sessions that ended without a hook.
p=$PPID AGENT="" PID=""
for _ in 1 2 3 4 5 6; do
  read -r pp comm <<<"$(ps -o ppid=,comm= -p "$p" 2>/dev/null)"
  case "${comm##*/}" in claude) AGENT=claude PID=$p; break ;; codex) AGENT=codex PID=$p; break ;; esac
  [ -n "$pp" ] && [ "$pp" -gt 1 ] || break
  p=$pp
done
[ -n "$AGENT" ] || AGENT=$([ -n "$CLAUDECODE" ] && echo claude || echo codex)

mkdir -p "$DIR"
F="$DIR/$SID"
OLD=$(cut -f2 "$F" 2>/dev/null)
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$AGENT" "$STATE" "$CWD" "$PID" "$(date +%s)" "${TMUX%%,*}" "$TMUX_PANE" > "$F.tmp" && mv "$F.tmp" "$F"
# Tool hooks fire on every call; only a state change wakes the bar.
[ "$OLD" = "$STATE" ] || { command -v sketchybar >/dev/null && sketchybar --trigger agent_status_change >/dev/null 2>&1 & }
exit 0
