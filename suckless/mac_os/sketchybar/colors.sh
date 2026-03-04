#!/opt/homebrew/bin/bash

# Color definitions
export WHITE=0xffffffff
export DARK_TEXT=$WHITE
export LIGHT_TEXT=$WHITE
export TRANSPARENT_TEXT=0x00ffffff

# Detect system appearance
APPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

if [ "$APPEARANCE" = "Dark" ]; then
	# Dark mode colors
	export TEXT_COLOR=$LIGHT_TEXT
else
	# Light mode colors
	export TEXT_COLOR=$DARK_TEXT
fi

# Transparent
export BAR_COLOR=0x00000000
export ITEM_BG_COLOR=0x00000000
export BACKGROUND_1=0x90202030 
export ACCENT_TERTIARY=0xffF74C00       # Orange
export APPLE=
