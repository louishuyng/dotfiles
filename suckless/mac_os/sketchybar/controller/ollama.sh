#!/usr/bin/env sh

OLLAMA_PROCESS=$(pgrep ollama)

BLUE=0xff3FB18E
GREY=0xff7F7F7F

if [[ $OLLAMA_PROCESS != "" ]]; then
  sketchybar --set $NAME icon.color=$BLUE
else
  sketchybar --set $NAME icon.color=$GREY
fi
