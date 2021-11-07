#!/usr/bin/env bash

sketchybar -m set battery label $(pmset -g batt | awk '{print $3}'|tail -1|sed -E 's/(.{1,2}%);/\1/')
