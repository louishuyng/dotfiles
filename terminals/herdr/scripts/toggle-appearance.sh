#!/opt/homebrew/bin/bash
# Flip macOS dark mode. herdr follows via theme.auto_switch, and tmux/nvim/ghostty
# via the com.user.theme-watcher launchd daemon. Manual theme selection in herdr
# Settings disables Follow system; re-enable it there to restore the policy.
# Lives in a script rather than inline TOML to avoid nesting quotes in osascript.

set -euo pipefail

osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
