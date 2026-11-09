#!/bin/bash
# pane-split.sh <down|right> — split the focused pane and give the new one a fixed share,
# like tmux's split-window -l: 35% below, 50% to the right. pane.split takes no size, so
# both panes are resized after: weight p/(1-p) against the old pane's 1. The old pane's
# weight is set too because a tab's first split doesn't start it at 1.
set -euo pipefail

case "$1" in
  down) weight=0.5385 ;;  # 35%
  right) weight=1 ;;      # 50%
  *) echo "usage: pane-split.sh down|right" >&2; exit 2 ;;
esac
old=$(herdr-app status | jq -er .focused_pane)
pane=$(herdr-app do pane.split --direction "$1" | jq -er .pane)
herdr-app do layout.resize --id "$old" --weight 1 >/dev/null
herdr-app do layout.resize --id "$pane" --weight "$weight" >/dev/null
