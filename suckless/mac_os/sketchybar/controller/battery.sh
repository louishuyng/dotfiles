#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

# Battery Icons
BATTERY_100=􀛨
BATTERY_75=􀺸
BATTERY_50=􀺶
BATTERY_25=􀛩
BATTERY_0=􀛪

RED=0xffff0000
YELLOW=0xffffff00
ORANGE=0xffffa500
GREEN=0xff60ff60

DRAWING=on
COLOR=$WHITE
case ${PERCENTAGE} in
  [8-9][0-9]|100) ICON=$BATTERY_100; COLOR=$GREEN
  ;;
  [6-8][0-9]) ICON=$BATTERY_75; COLOR=$YELLOW
  ;;
  [3-5][0-9]) ICON=$BATTERY_50; COLOR=$ORANGE
  ;;
  [1-2][0-9]) ICON=$BATTERY_25; COLOR=$RED
  ;;
  *) ICON=$BATTERY_0; COLOR=$RED
esac

if [[ $CHARGING != "" ]]; then
    ICON=""
    COLOR=0xffeed49f
fi

sketchybar --set $NAME \
    icon=$ICON \
    label="${PERCENTAGE}% |" \
    icon.color=${COLOR}
