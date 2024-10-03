#!/usr/bin/env bash

if [[ $(yabai -m query --windows --space mouse | jq 'length') -eq 1 ]]; then
  yabai -m space --padding abs:0:27:0:0
else
  yabai -m space --padding abs:0:27:10:0
fi
