#!/bin/bash
# pane-resize.sh <left|right|up|down> — move the focused pane's border that way, like
# tmux's resize-pane -L/-R/-U/-D. The app only resizes by weight (layout.resize), so this
# finds the focused pane's branch in the nearest row (left/right) or column (up/down) of
# herdr-core's layout document (an internal file) and grows or shrinks that branch.
set -euo pipefail

docs="$HOME/.local/state/herdr-core/default/docs.json"
pane=$(herdr-app status | jq -er .focused_pane)
read -r node weight < <(python3 -I - "$docs" "$pane" "$1" <<'EOF'
import json, sys

docs, pane, direction = sys.argv[1:4]
axis = "row" if direction in ("left", "right") else "column"
toward_start = direction in ("left", "up")

def find(node, trail):
    if node.get("id") == pane:
        return trail
    for i, child in enumerate(node.get("children", [])):
        found = find(child, trail + [(node, i)])
        if found:
            return found

for space in json.load(open(docs))["herdr-app"]["value"]["spaces"]:
    for tab in space["tabs"]:
        trail = find(tab["root"], [])
        if not trail:
            continue
        for parent, i in reversed(trail):
            kids = parent.get("children", [])
            if parent.get("type") != axis or len(kids) < 2:
                continue
            branch = kids[i]
            weight = branch.get("size", {}).get("weight", 1)
            # The last branch's border is before it, the others' after it: moving the
            # border toward the start grows the last branch and shrinks the others.
            grow = (i == len(kids) - 1) == toward_start
            weight = min(10, weight * 1.25) if grow else max(0.1, weight * 0.8)
            print(branch["id"], round(weight, 4))
            sys.exit()
EOF
) || exit 0
[ -n "${node:-}" ] && herdr-app do layout.resize --id "$node" --weight "$weight" >/dev/null
