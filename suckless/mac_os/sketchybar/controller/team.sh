STATUS_LABEL=$(lsappinfo info -only StatusLabel "Microsoft Teams (work or school)")
LABEL=""

if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"
fi

if [[ $LABEL == "" ]]; then
  LABEL=0
fi

sketchybar --set $NAME label="${LABEL}" label.drawing=on
