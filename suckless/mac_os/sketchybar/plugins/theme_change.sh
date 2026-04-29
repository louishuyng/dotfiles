#!/opt/homebrew/bin/bash

# Determine target theme
if defaults read -g AppleInterfaceStyle &>/dev/null 2>&1; then
    TARGET="dark"
else
    TARGET="light"
fi

# Skip if already on this theme
if diff -q "$CONFIG_DIR/colors.sh" "$CONFIG_DIR/themes/${TARGET}.sh" &>/dev/null; then
    exit 0
fi

# Copy matching theme over colors.sh
cp "$CONFIG_DIR/themes/${TARGET}.sh" "$CONFIG_DIR/colors.sh"

# Source new colors
source "$CONFIG_DIR/colors.sh"

# Update bar + all items in place
sketchybar --reload
