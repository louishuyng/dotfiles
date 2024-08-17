#!/usr/bin/env bash

if [[ $(yabai -m query --windows --space mouse | jq 'length') -eq 1 ]]; then
  yabai -m space --padding abs:0:0:0:0
else
  yabai -m space --padding abs:0:0:10:0
fi
