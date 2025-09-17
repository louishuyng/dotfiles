#!/opt/homebrew/bin/bash

POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

source ~/.dotfiles/suckless/mac_os/sketchybar/colors.sh
source ~/.dotfiles/suckless/mac_os/sketchybar/icons.sh

github_bell=(
  update_freq=60
  icon=$BELL
  icon.font="$LABEL:Bold:12.0"
  icon.color=$BLUE
  label=$LOADING
  label.highlight_color=$BLUE
  popup.align=left
  script="$PLUGIN_DIR/github.sh"
  click_script="$POPUP_CLICK_SCRIPT"
)

github_template=(
  drawing=off
  background.corner_radius=12
  padding_left=7
  padding_right=7
  icon.background.height=2
  icon.background.y_offset=-12
)

sketchybar --add event github.update                    \
           --add item github.bell right                 \
           --set github.bell "${github_bell[@]}"        \
           --subscribe github.bell  mouse.entered       \
                                    mouse.exited        \
                                    mouse.exited.global \
                                    github.update       \
                                                        \
           --add item github.template popup.github.bell \
           --set github.template "${github_template[@]}"

