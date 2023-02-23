#!/usr/bin/env sh

sketchybar --add   space          space_template left                \
           --set   space_template icon.color=0xff76add0              \
                                  label.drawing=off                  \
                                  drawing=off                        \
                                  updates=on                         \
                                  associated_display=1               \
                                  label.font="$FONT:Black:12.4"      \
                                  icon.font="$FONT:Bold:12.4"        \
                                  icon.padding_right=6               \
                                  icon.padding_left=2                \
                                  icon.y_offset=2                \
                                  background.padding_left=0          \
                                  background.padding_right=1         \
                                  icon.background.height=2           \
                                  icon.background.color=$ICON_COLOR  \
                                  icon.background.color=$ICON_COLOR  \
                                  icon.background.y_offset=-13       \
                                  click_script="$SPACE_CLICK_SCRIPT" \
                                  ignore_association=on              \
                                                                     \
           --clone spaces_1.label label_template                     \
                                  associated_display=1               \
                                  label.width=45                     \
                                  label.align=center                 \
                                  position=left                      \
                                  drawing=on                         \
                                                                     \
           --clone spaces_1.org   space_template                     \
           --set   spaces_1.org   associated_space=1                 \
                                  icon=org                           \
                                  icon.highlight_color=0xffab79a7    \
                                  icon.background.color=0xffab79a7   \
                                  drawing=on                         \
                                  script="$PLUGIN_DIR/space.sh"      \
                                                                     \
           --clone spaces_1.debug  space_template                     \
           --set   spaces_1.debug  associated_space=2                 \
                                  icon=debug                           \
                                  icon.highlight_color=0xffab79a7    \
                                  icon.background.color=0xffab79a7   \
                                  drawing=on                         \
                                  script="$PLUGIN_DIR/space.sh"      \
                                                                     \
           --clone spaces_1.vim   space_template                     \
           --set   spaces_1.vim   associated_space=3                 \
                                  icon="$VIM"                          \
                                  icon.highlight_color=0xff60ff60    \
                                  icon.background.color=0xff60ff60   \
                                  drawing=on                         \
                                  script="$PLUGIN_DIR/space.sh"      \
                                                                     \
           --clone spaces_1.www   space_template                     \
           --set   spaces_1.www   associated_space=4                 \
                                  icon=www                           \
                                  icon.highlight_color=0xffab79a7    \
                                  icon.background.color=0xffab79a7   \
                                  drawing=on                         \
                                  script="$PLUGIN_DIR/space.sh"      \
                                                                     \
           --clone spaces_1.work space_template                     \
           --set   spaces_1.work associated_space=5                 \
                                  icon=work                          \
                                  icon.highlight_color=0xffab79a7    \
                                  icon.background.color=0xffab79a7   \
                                  drawing=on                         \
                                  script="$PLUGIN_DIR/space.sh"      \
