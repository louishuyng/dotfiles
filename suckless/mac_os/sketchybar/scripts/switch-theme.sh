#!/bin/bash

# Sketchybar theme switcher

THEME="$1"
DARK_THEME="$HOME/.dotfiles/suckless/mac_os/sketchybar/themes/dark.sh"
LIGHT_THEME="$HOME/.dotfiles/suckless/mac_os/sketchybar/themes/light.sh"
COLOR_FILE="$HOME/.dotfiles/suckless/mac_os/sketchybar/colors.sh"

if [ -z "$THEME" ]; then
    # Auto-detect if no theme specified
    if defaults read -g AppleInterfaceStyle &>/dev/null; then
        THEME="dark"
    else
        THEME="light"
    fi
fi

case "$THEME" in
    dark)
        THEME_FILE="$DARK_THEME"
        ;;
    light)
        THEME_FILE="$LIGHT_THEME"
        ;;
    *)
        echo "Error: Invalid theme '$THEME'. Use 'dark' or 'light'."
        exit 1
        ;;
esac

if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

# Copy the theme to colors.sh
cp "$THEME_FILE" "$COLOR_FILE"

# Restart sketchybar to apply theme
if pgrep -x sketchybar >/dev/null; then
    brew services restart sketchybar 2>/dev/null || sketchybar --reload 2>/dev/null
fi

echo "Switched sketchybar theme to: $THEME"
