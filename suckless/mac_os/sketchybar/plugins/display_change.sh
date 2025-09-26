#!/opt/homebrew/bin/bash

AEROSPACE=/opt/homebrew/bin/aerospace
SKETCHYBAR=/opt/homebrew/bin/sketchybar

ZEN_BROWSER_ID="app.zen-browser.zen"
LENS_ID="com.electron.kontena-lens"

move_app_windows() {
    local app_id="$1"
    local workspace="$2"

    $AEROSPACE list-windows --monitor all --app-bundle-id "$app_id" --format '%{window-id}' | \
        xargs -I {} $AEROSPACE move-node-to-workspace --window-id {} "$workspace" 2>/dev/null
}

monitor_count=$($AEROSPACE list-monitors | wc -l)

if [ "$monitor_count" -gt 1 ]; then
    move_app_windows "$ZEN_BROWSER_ID" "External-2"
    move_app_windows "$LENS_ID" "External-1"
else
    move_app_windows "$ZEN_BROWSER_ID" "Web"
    move_app_windows "$LENS_ID" "Infra"
fi

$SKETCHYBAR --trigger aerospace_workspace_change
