#!/bin/bash

# tmux theme switcher - applies the appropriate theme config to all running tmux sessions

# Use absolute path to tmux
TMUX_BIN="/opt/homebrew/bin/tmux"

THEME="$1"
DARK_CONF="$HOME/.dotfiles/terminals/tmux/plugins/dark.conf"
LIGHT_CONF="$HOME/.dotfiles/terminals/tmux/plugins/light.conf"

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
        CONF_FILE="$DARK_CONF"
        ;;
    light)
        CONF_FILE="$LIGHT_CONF"
        ;;
    *)
        echo "Error: Invalid theme '$THEME'. Use 'dark' or 'light'."
        exit 1
        ;;
esac

if [ ! -f "$CONF_FILE" ]; then
    echo "Error: Theme config file not found: $CONF_FILE"
    exit 1
fi

# Check if tmux is running
if ! pgrep -x tmux >/dev/null; then
    echo "tmux is not running, skipping theme switch"
    exit 0
fi

# Find all tmux sockets and apply theme to each server
applied=0
for socket_dir in /private/tmp/tmux-* /tmp/tmux-*; do
    [ -d "$socket_dir" ] || continue
    
    for socket in "$socket_dir"/default "$socket_dir"/default-*; do
        [ -S "$socket" ] || continue
        
        # Source the theme file for this server
        if "$TMUX_BIN" -S "$socket" source-file "$CONF_FILE" 2>/dev/null; then
            applied=$((applied + 1))
            
            # Refresh all clients connected to this server
            "$TMUX_BIN" -S "$socket" list-clients -F '#{client_name}' 2>/dev/null | while read -r client; do
                "$TMUX_BIN" -S "$socket" refresh-client -t "$client" 2>/dev/null
            done
            
            # Also do a general refresh without specifying client
            "$TMUX_BIN" -S "$socket" refresh-client 2>/dev/null
        fi
    done
done

if [ $applied -gt 0 ]; then
    echo "Switched tmux theme to: $THEME ($applied socket(s) updated)"
else
    echo "Switched tmux theme to: $THEME (warning: no sockets updated)"
fi
