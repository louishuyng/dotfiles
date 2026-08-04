#!/opt/homebrew/bin/bash
# Flip macOS dark mode. herdr follows via theme.auto_switch, and tmux/nvim/ghostty
# via the com.user.theme-watcher launchd daemon — so this one key moves everything.
# Lives in a script rather than inline TOML to avoid nesting quotes in osascript.

set -euo pipefail

osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
