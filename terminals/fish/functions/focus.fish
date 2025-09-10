function focus --description "Now I focus on something"
    # Define list options with icons and corresponding text labels
    set -l LIST_OPTIONS \
        "󰮡 programming" \
        " reading" \
        "󱢊 relaxing" \
        " deep-work" \
        " meeting" \
        " break" \
        " plan"
    # Use gum choose and capture the result
    set -l FOCUS_SELECTION (printf "%s\n" $LIST_OPTIONS | gum choose \
        --header "🎯 What are you focusing on?")

    # Check if a selection was made
    if test -n "$FOCUS_SELECTION"
        # Extract the icon (first character) and text (everything after the space)
        set -l FOCUS_ICON (echo $FOCUS_SELECTION | cut -c1)
        set -l FOCUS_TEXT (echo $FOCUS_SELECTION | cut -d' ' -f2-)

        # Set sketchybar with separate icon and label
        sketchybar --set focus icon="$FOCUS_ICON" label="$FOCUS_TEXT"
    else
        sketchybar --set focus icon="" label="void"
    end
end
