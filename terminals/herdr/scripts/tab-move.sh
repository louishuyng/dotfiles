#!/opt/homebrew/bin/bash
# Move the focused tab one position left or right.
#
# herdr's CLI has no `tab move`, so this speaks the socket API's tab.move method
# directly over ~/.config/herdr/herdr.sock. That is an internal protocol (19 at
# time of writing) which the CLI deliberately does not expose, so this is the
# most fragile binding in the config — see tests/herdr/tabmove.bats.
#
# Usage: tab-move.sh <left|right> [--dry-run]
#   --dry-run prints "<tab_id> <insert_index>" instead of sending, so the index
#   arithmetic is testable without a running server.

HERDR_BIN="${HERDR_BIN:-herdr}"

direction="$1"
dry_run=0
[[ "$2" == "--dry-run" ]] && dry_run=1

if [[ "$direction" != "left" && "$direction" != "right" ]]; then
  echo "tab-move: usage: tab-move.sh <left|right> [--dry-run]" >&2
  exit 2
fi

json=$("$HERDR_BIN" tab list 2>/dev/null) || exit 2

focused_ws=$(printf '%s' "$json" | jq -r '.result.tabs[]? | select(.focused == true) | .workspace_id' 2>/dev/null) || exit 2
focused_id=$(printf '%s' "$json" | jq -r '.result.tabs[]? | select(.focused == true) | .tab_id' 2>/dev/null) || exit 2
[[ -z "$focused_id" ]] && exit 2

# `number` does not renumber after a move, so position must come from list
# order (0-based) within the focused tab's own workspace, not from `number`.
ws_tabs=$(printf '%s' "$json" | jq -c --arg ws "$focused_ws" '[.result.tabs[]? | select(.workspace_id == $ws)]' 2>/dev/null) || exit 2
n=$(printf '%s' "$ws_tabs" | jq 'length' 2>/dev/null) || exit 2
p=$(printf '%s' "$ws_tabs" | jq --arg id "$focused_id" 'map(.tab_id) | index($id)' 2>/dev/null) || exit 2
[[ -z "$p" || "$p" == "null" ]] && exit 2

# insert_index is 0-based into the pre-removal list ("insert before the item
# currently at that index"), which makes the two directions asymmetric —
# verified empirically against a live server.
insert_index=""
if [[ "$direction" == "right" ]]; then
  (( p + 1 < n )) && insert_index=$(( p + 2 ))
else
  (( p > 0 )) && insert_index=$(( p - 1 ))
fi

# At an edge there's nowhere to move — no-op rather than erroring, matching
# how `pane swap` no-ops at an edge.
[[ -z "$insert_index" ]] && exit 0

if [[ "$dry_run" -eq 1 ]]; then
  echo "$focused_id $insert_index"
  exit 0
fi

python3 - "$focused_id" "$insert_index" <<'PY'
import json
import os
import socket
import sys

tab_id, insert_index = sys.argv[1], int(sys.argv[2])
sock_path = os.path.expanduser("~/.config/herdr/herdr.sock")
req = {"id": "tab-move", "method": "tab.move", "params": {"tab_id": tab_id, "insert_index": insert_index}}

try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(sock_path)
    sock.sendall((json.dumps(req) + "\n").encode())
    buf = b""
    while b"\n" not in buf:
        chunk = sock.recv(4096)
        if not chunk:
            break
        buf += chunk
    sock.close()
except OSError as exc:
    print(f"tab-move: socket error: {exc}", file=sys.stderr)
    sys.exit(2)

line = buf.split(b"\n", 1)[0]
try:
    resp = json.loads(line)
except json.JSONDecodeError:
    print(f"tab-move: malformed response: {line!r}", file=sys.stderr)
    sys.exit(2)

if "error" in resp:
    print(f"tab-move: {resp['error']}", file=sys.stderr)
    sys.exit(2)
PY
