#!/usr/bin/env sh

CONTEXT=$(grep "current-context:" ~/.kube/config | awk '{print $2}')

sketchybar --set $NAME label="$CONTEXT |"
