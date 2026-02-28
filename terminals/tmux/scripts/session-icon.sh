#!/usr/bin/env bash

# Get the current session name
SESSION=$(tmux display-message -p '#S')

# Return appropriate icon based on session name
case "$SESSION" in
    "LX14")
        echo "󰱯"
        ;;
    "RCODE")
        echo ""
        ;;
    "ROPS")
        echo "󱃾"
        ;;
    *)
        echo " "
        ;;
esac
