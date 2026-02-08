#!/bin/bash

# System appearance monitor - watches for macOS system appearance changes
# and automatically updates tmux, sketchybar, and k9s themes

TMUX_SWITCHER="$HOME/.dotfiles/terminals/tmux/scripts/switch-theme.sh"
SKETCHYBAR_SWITCHER="$HOME/.dotfiles/suckless/mac_os/sketchybar/scripts/switch-theme.sh"
K9S_SWITCHER="$HOME/.config/k9s/scripts/switch-theme.sh"
LOG_FILE="/tmp/appearance-monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_appearance() {
    if defaults read -g AppleInterfaceStyle &>/dev/null; then
        echo "dark"
    else
        echo "light"
    fi
}

# Function to switch all themes
switch_all_themes() {
    local theme=$1
    log "Switching all applications to $theme theme"
    
    # Switch tmux
    if [ -x "$TMUX_SWITCHER" ]; then
        "$TMUX_SWITCHER" "$theme" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Switch sketchybar
    if [ -x "$SKETCHYBAR_SWITCHER" ]; then
        "$SKETCHYBAR_SWITCHER" "$theme" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Switch k9s
    if [ -x "$K9S_SWITCHER" ]; then
        "$K9S_SWITCHER" "$theme" 2>&1 | tee -a "$LOG_FILE"
    fi
}

# Initial theme setup
current_theme=$(get_appearance)
log "Starting appearance monitor with initial theme: $current_theme"
switch_all_themes "$current_theme"

# Monitor for changes using a simple polling approach
# We check every 2 seconds for appearance changes
while true; do
    new_theme=$(get_appearance)
    
    if [ "$new_theme" != "$current_theme" ]; then
        log "Appearance changed from $current_theme to $new_theme"
        current_theme=$new_theme
        
        # Switch all themes
        switch_all_themes "$new_theme"
    fi
    
    sleep 2
done
