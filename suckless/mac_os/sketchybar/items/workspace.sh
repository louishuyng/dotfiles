#!/opt/homebrew/bin/bash

# One item per Aerospace workspace
# Labels are shown/hidden based on occupation; active one highlighted in blue

declare -A WS_LABELS
WS_LABELS=(
	[Any]="ANY"
	[Chat]="CHAT"
	[Dev]="DEV"
	[Inbox]="INBOX"
	[Infra]="INFRA"
	[Planing]="PLAN"
	[Reading]="READ"
	[Terminal]="TERM"
	[Virtual]="VIRT"
	[Web]="WEB"
)

WORKSPACES=(Virtual Infra Dev Terminal Web Reading Planing Chat Inbox Any)

first=true
for ws in "${WORKSPACES[@]}"; do
	label="${WS_LABELS[$ws]}"
	if $first; then
		pad_left=0
		first=false
	else
		pad_left=2
	fi
	sketchybar --add item "workspace.$ws" left \
		--set "workspace.$ws" \
			label="$label" \
			label.font="BlexMono Nerd Font:Regular:13.0" \
			label.color=0xff3b4261 \
			label.padding_left=6 \
			label.padding_right=6 \
			icon.drawing=off \
			padding_left="$pad_left" \
			padding_right=2 \
			drawing=off \
			click_script="aerospace workspace $ws" \
			script="$PLUGIN_DIR/workspace.sh" \
		--subscribe "workspace.$ws" aerospace_workspace_change
done

# Bracket all workspace items together with a unified background
sketchybar --add bracket workspaces \
    workspace.Virtual workspace.Infra workspace.Dev workspace.Terminal \
    workspace.Web workspace.Reading workspace.Planing workspace.Chat \
    workspace.Inbox workspace.Any \
    --set workspaces \
        background.color=0xff000000 \
        background.corner_radius=0 \
        background.height=24
