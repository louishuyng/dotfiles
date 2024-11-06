#!/bin/bash
olddir=$(pwd)

cd ~/.dotfiles/sketchybar-app-font

git pull

pnpm install

pnpm run build:install ~/.dotfiles/suckless/mac_os/sketchybar/plugins/icon_map_fn.sh

cd $olddir
