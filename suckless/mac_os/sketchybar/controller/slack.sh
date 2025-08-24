#!/usr/bin/env sh
STATUS_LABEL=$(lsappinfo info -only StatusLabel "Slack")

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"

    if [[ $LABEL == "" ]]; then
        ICON_COLOR="0xffa6da95"
    elif [[ $LABEL == "•" ]]; then
        ICON_COLOR="0xffeed49f"
    elif [[ $LABEL =~ ^[0-9]+$ ]]; then
        ICON_COLOR="0xffed8796"
    else
        exit 0
    fi

    sketchybar --set $NAME label="${LABEL}" icon.color=${ICON_COLOR} label.drawing=on icon.drawing=on
else
    sketchybar --set $NAME label.drawing=off icon.drawing=off
fi
