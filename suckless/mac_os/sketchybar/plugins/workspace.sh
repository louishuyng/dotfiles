#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# FOCUSED_WORKSPACE is set by aerospace.toml's exec-on-workspace-change.
# On initial load (no event), fall back to querying aerospace directly.
if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
fi

# Note: macOS /bin/bash is 3.2 (no associative arrays). Use a case statement.
case "$FOCUSED_WORKSPACE" in
  Any)      label="ANY" ;;
  Chat)     label="CHAT" ;;
  Dev)      label="DEV" ;;
  Inbox)    label="INBOX" ;;
  Planing)  label="PLAN" ;;
  Reading)  label="READ" ;;
  Terminal) label="TERM" ;;
  Virtual)  label="VIRTUAL" ;;
  Web)      label="WEB" ;;
  *)        label="$FOCUSED_WORKSPACE" ;;
esac

sketchybar --set "$NAME" label="$label" label.color=$WORKSPACE_ACTIVE_COLOR
