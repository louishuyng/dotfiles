#!/bin/bash

# A single pill on the left of the bar that shows the currently focused
# Aerospace workspace. Triggered by the `aerospace_workspace_change` event
# emitted from aerospace.toml's `exec-on-workspace-change`.

# Register the custom event fired by aerospace.toml's exec-on-workspace-change.
# Without this, --trigger/--subscribe silently no-op and the label never updates.
sketchybar --add event aerospace_workspace_change

workspace=(
  label.font="$FONT:SemiBold:14.0"
  label.padding_left=6
  label.padding_right=6
  icon.drawing=off
  padding_left=4
  padding_right=2
  background.drawing=off
  updates=on
  script="$PLUGIN_DIR/workspace.sh"
)

sketchybar --add item workspace left            \
           --set workspace "${workspace[@]}"    \
           --subscribe workspace aerospace_workspace_change

# Prime the label with the currently focused workspace so something is
# visible before the first workspace switch.
sketchybar --trigger aerospace_workspace_change \
  FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
