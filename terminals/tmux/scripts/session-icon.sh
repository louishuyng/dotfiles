#!/usr/bin/env bash

# Get the current session name
SESSION=$(tmux display-message -p '#S')

# Return appropriate icon based on session name
case "$SESSION" in
    "LX-CONFIG")
        echo "󰱯 "
        ;;
    "LX-REGASK")
        echo " "
        ;;
    "LX-RESEARCH")
        echo "󱃾 "
        ;;
    *)
        echo ""
        ;;
esac
