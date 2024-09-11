#!/usr/bin/env sh

OLLAMA_PROCESS=$(pgrep ollama)

BLUE=0xff73DACA
GREY=0xff7F7F7F

if [[ $OLLAMA_PROCESS != "" ]]; then
  sketchybar --set $NAME icon.color=$BLUE icon=􀪏  label="Ollama/On"
else
  sketchybar --set $NAME label="Ollama/Off" icon.color=$GREY icon=􀩼
fi
