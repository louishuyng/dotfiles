#!/opt/homebrew/bin/bash

source "$CONFIG_DIR/colors.sh"

# Check current popup state
POPUP_STATE=$(sketchybar --query space | jq -r '.popup.drawing')

# If popup is currently open, just close it
if [ "$POPUP_STATE" = "on" ]; then
    sketchybar --set space popup.drawing=off
    exit 0
fi

# Get current workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Get all workspaces
ALL_WORKSPACES=$(aerospace list-workspaces --all)

# Remove old popup items first
for ws in $ALL_WORKSPACES; do
    sketchybar --remove "space.workspace_$ws" 2>/dev/null
done
sketchybar --remove space.no_workspaces 2>/dev/null

# Counter for positioning
counter=0

# Create popup items for each workspace except current one
for workspace in $ALL_WORKSPACES; do
    if [ "$workspace" != "$FOCUSED_WORKSPACE" ]; then
        # Get window count for this workspace
        WINDOW_COUNT=$(aerospace list-windows --workspace "$workspace" 2>/dev/null | wc -l | tr -d ' ')

        # Set icon based on window count
        if [ "$WINDOW_COUNT" -gt 0 ]; then
            ICON="󰖯"  # Workspace with windows
            ICON_COLOR=$ACCENT_SECONDARY
        else
            ICON="󰄰"  # Empty workspace
            ICON_COLOR=$GREY
        fi

        sketchybar --add item "space.workspace_$workspace" popup.space \
                   --set "space.workspace_$workspace" \
                         icon="$ICON" \
                         icon.color="$ICON_COLOR" \
                         icon.font="JetbrainsMono Nerd Font Propo:Semibold:14.0" \
                         icon.padding_left=8 \
                         icon.padding_right=6 \
                         label="$workspace" \
                         label.color=$POPUP_LABEL_COLOR \
                         label.font="JetbrainsMono Nerd Font Propo:Medium:13.0" \
                         label.padding_left=0 \
                         label.padding_right=8 \
                         background.color=$BACKGROUND_1 \
                         background.drawing=on \
                         background.corner_radius=6 \
                         padding_left=4 \
                         padding_right=4 \
                         click_script="aerospace workspace $workspace; sketchybar --set space popup.drawing=off"

        counter=$((counter + 1))
    fi
done

# If no other workspaces, show a message
if [ $counter -eq 0 ]; then
    sketchybar --add item space.no_workspaces popup.space \
               --set space.no_workspaces \
                     icon="󰔫" \
                     icon.color=$GREY \
                     label="No other workspaces" \
                     label.color=$GREY \
                     background.drawing=off \
                     click_script="sketchybar --set space popup.drawing=off"
fi

# Open the popup
sketchybar --set space popup.drawing=on
