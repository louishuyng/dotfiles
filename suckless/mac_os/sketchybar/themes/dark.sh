#!/opt/homebrew/bin/bash

### Dark Theme for Sketchybar - Tokyo Night
### Background matches nvim (#1a1b26) for seamless integration

# Base colors - Tokyo Night palette
export BLACK=0xff1a1b26
export WHITE=0xffc0caf5
export RED=0xfff7768e
export GREEN=0xff9ece6a
export BLUE=0xff7aa2f7
export YELLOW=0xffe0af68
export ORANGE=0xffff9e64
export MAGENTA=0xffbb9af7
export CYAN=0xff2ac3de
export PURPLE=0xffbb9af7
export GREY=0xff565f89
export LIGHT_GREY=0xff737aa2
export DARK_GREY=0xff16161e
export TRANSPARENT=0x00000000

# Battery colors - Tokyo Night status indication
export BATTERY_1=0xff9ece6a  # Green  - Full
export BATTERY_2=0xff7aa2f7  # Blue   - Good
export BATTERY_3=0xffe0af68  # Yellow - Medium
export BATTERY_4=0xffff9e64  # Orange - Low
export BATTERY_5=0xfff7768e  # Red    - Critical

# General bar colors - Matches nvim background
export BAR_COLOR=0x00000000              # Transparent bar
export BAR_BORDER_COLOR=0xff24283b       # surface0
export BACKGROUND_1=0xe61a1b26           # Pill background (90% opacity)
export BACKGROUND_2=0xff16161e           # Darker bg
export ICON_COLOR=0xff565f89             # comment
export LABEL_COLOR=0xffc0caf5            # fg
export POPUP_BACKGROUND_COLOR=0xf01a1b26 # nvim bg
export POPUP_BORDER_COLOR=0xff7aa2f7     # blue
export SHADOW_COLOR=0x80000000           # Soft shadow

# Accent colors - Tokyo Night harmonious palette
export ACCENT_PRIMARY=0xff7aa2f7         # Blue
export ACCENT_SECONDARY=0xff9ece6a       # Green
export ACCENT_TERTIARY=0xffff9e64        # Orange
export ACCENT_QUATERNARY=0xffbb9af7      # Purple
export ACCENT_PINK=0xffff007c            # Pink
export ACCENT_TEAL=0xff2ac3de            # Cyan
export ACCENT_GOLD=0xffe0af68            # Yellow

# Specialized UI colors
export SEPARATOR_COLOR=0x60565f89        # Subtle grey
export HOVER_BG=0x4024283b               # Hover surface
export ACTIVE_BG=0x603d59a1              # Active selection

# Popup/contrast colors
export POPUP_LABEL_COLOR=0xffc0caf5      # fg
export POPUP_ICON_COLOR=0xff565f89       # comment
export CONTRAST_TEXT=0xffc0caf5          # fg
