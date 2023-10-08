#!/bin/bash

COUNT_LAWBITE_WORKS=$(grep -c "TODO" ~/Dev/org/lawbite.org)

sketchybar -m --set $NAME label="Lawbite: $COUNT_LAWBITE_WORKS"
