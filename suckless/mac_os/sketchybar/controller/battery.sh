#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

COLOR="0xffffffff"
ICON=""

if [[ $CHARGING != "" ]]; then
    ICON=""
    COLOR=0xffeed49f
fi

sketchybar --set $NAME \
    icon=$ICON \
    label="${PERCENTAGE}%" \
    icon.color=${COLOR}
