#!/bin/bash

COUNT_LAWBITE_WORKS=$(grep -c "TODO" ~/Dev/org/lawbite.org)

sketchybar -m --set $NAME label="$COUNT_LAWBITE_WORKS |"
