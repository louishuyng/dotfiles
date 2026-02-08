#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

WORKSPACE_ID="$1"

# Get currently focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Get workspaces for each monitor
MONITOR_1_WORKSPACES=$(aerospace list-workspaces --monitor 1)
MONITOR_2_WORKSPACES=$(aerospace list-workspaces --monitor 2)

# Check if this workspace is on monitor 1 or 2
ON_MONITOR_1=""
ON_MONITOR_2=""

for ws in $MONITOR_1_WORKSPACES; do
    if [ "$ws" = "$WORKSPACE_ID" ]; then
        ON_MONITOR_1="true"
        break
    fi
done

for ws in $MONITOR_2_WORKSPACES; do
    if [ "$ws" = "$WORKSPACE_ID" ]; then
        ON_MONITOR_2="true"
        break
    fi
done

# Show workspace if:
# 1. It's the currently focused workspace (global focus)
# 2. OR it's one of the "representative" workspaces from each monitor
SHOULD_SHOW="false"

if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    # Always show the currently focused workspace
    SHOULD_SHOW="true"
elif [ "$ON_MONITOR_1" = "true" ] && [ "$WORKSPACE_ID" = "1" ]; then
    # Show workspace 1 as representative of monitor 1
    SHOULD_SHOW="true"
elif [ "$ON_MONITOR_2" = "true" ] && [ "$WORKSPACE_ID" = "4" ]; then
    # Show workspace 4 as representative of monitor 2 (adjust this number as needed)
    SHOULD_SHOW="true"
fi

if [ "$SHOULD_SHOW" = "true" ]; then
    # Show the workspace item
    sketchybar --set "$NAME" drawing=on
    
    if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
        # Active workspace styling - more noticeable text
        sketchybar --set "$NAME" \
                   background.drawing=on \
                   background.color=$BACKGROUND_2 \
                   background.corner_radius=6 \
                   background.height=26 \
                   background.border_width=0 \
                   icon.color=$POPUP_ICON_COLOR \
                   icon.font="SF Pro:Semibold:14.0" \
                   label.color=$POPUP_LABEL_COLOR
    else
        # Workspace visible on other display but not focused - subtle styling
        sketchybar --set "$NAME" \
                   background.drawing=on \
                   background.color=$BACKGROUND_1 \
                   background.corner_radius=6 \
                   background.height=26 \
                   background.border_width=0 \
                   icon.color=$GREY \
                   icon.font="SF Pro:Medium:14.0" \
                   label.color=$GREY
    fi
else
    # Hide workspace that's not active on any display
    sketchybar --set "$NAME" drawing=off
fi



# MAIN_COLOR=0xffa17fa7
# ACCENT_COLOR=0xffe19286
#
# echo $NAME > ~/debug_skekychybar
#
# if [ "$1" = "change-focused-window" ]; then
#     echo "change-focused-window"
#     focused_window_info=$(aerospace list-windows --focused)
#     focused_window_id=$(echo $focused_window_info | awk -F ' \\| ' '{print $1}')
#     if [ "$2" = "$focused_window_id" ]; then
#         sketchybar --set $NAME icon.color=$ACCENT_COLOR
#     else
#         sketchybar --set $NAME icon.color=$MAIN_COLOR
#     fi
# fi
#
# if [ "$1" = "change-focused-workspace" ]; then
#     echo "change-focused-workspace"
#     focused_workspace=$(aerospace list-workspaces --focused)
#     if [ "$2" = "$focused_workspace" ]; then
#         sketchybar --set $NAME label.color=$ACCENT_COLOR
#     else
#         sketchybar --set $NAME label.color=$MAIN_COLOR
#     fi
# fi
#
# if [ "$1" = "move-window-within-workspace" ]; then
#     echo "move-window-within-workspace"
#     focused_workspace=$(aerospace list-workspaces --focused)
#     if [ "$2" = "$focused_workspace" ]; then
#         sketchybar --set $NAME label.color=$ACCENT_COLOR
#     else
#         sketchybar --set $NAME label.color=$MAIN_COLOR
#     fi
# fi
