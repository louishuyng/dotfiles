#!/opt/homebrew/bin/bash

# One item per Aerospace workspace

declare -A WS_LABELS
WS_LABELS=(
	[Any]="ANY"
	[Chat]="CHAT"
	[Dev]="DEV"
	[Inbox]="INBOX"
	[Planing]="PLAN"
	[Reading]="READ"
	[Terminal]="TERM"
	[Virtual]="VIRTUAL"
	[Web]="WEB"
)

WORKSPACES=(Virtual Dev Terminal Web Reading Planing Chat Inbox Any)

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
