#!/opt/homebrew/bin/bash

OLLAMA_PROCESS=$(pgrep LM Studio)

BLUE=0xff3FB18E
GREY=0xff7F7F7F

if [[ $OLLAMA_PROCESS != "" ]]; then
   pkill -9 LM Studio
   sketchybar --set $NAME background.color="" label="" \
                        label.padding_right=0                             \
                        label.padding_left=0                             \
                        icon.padding_left=0                             \
                        icon.padding_right=0                             \
                        background.padding_right=0 \
else
  open -a "LM Studio"
  sketchybar --set $NAME background.color=$BLUE label="AI" \
                        label.padding_right=7                             \
                        label.padding_left=5                             \
                        icon.padding_left=0                             \
                        icon.padding_right=0                             \
                        background.padding_right=7
fi
