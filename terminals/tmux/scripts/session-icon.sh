#!/usr/bin/env bash

# Get the current session name
SESSION=$(tmux display-message -p '#S')

# Return appropriate icon based on session name
case "$SESSION" in
    "LX14")
        echo ""
        ;;
    "Regask[Dev]")
        echo ""
        ;;
    "Regask[Ops]")
        echo "󰣳"
        ;;
    *)
        echo " "
        ;;
esac
