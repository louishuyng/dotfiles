#!/opt/homebrew/bin/bash

### Dark Theme for Sketchybar - OneDark
### Background matches nvim (#282c34) for seamless integration

# Base colors - OneDark palette
export BLACK=0xff282c34
export WHITE=0xffabb2bf
export RED=0xffe06c75
export GREEN=0xff98c379
export BLUE=0xff61afef
export YELLOW=0xffe5c07b
export ORANGE=0xffd19a66
export MAGENTA=0xffD38AEA
export CYAN=0xff56b6c2
export PURPLE=0xffc678dd
export GREY=0xff5c6370
export LIGHT_GREY=0xff5c6370
export DARK_GREY=0xff21252b
export TRANSPARENT=0x00000000

# Battery colors - OneDark status indication
export BATTERY_1=0xffA0C980  # Green - Full
export BATTERY_2=0xffDDB974  # Yellow - High
export BATTERY_3=0xffDDB974  # Orange - Medium
export BATTERY_4=0xffEB7279  # Red - Low
export BATTERY_5=0xffEB7279  # Red - Critical

# General bar colors - Matches nvim background
export BAR_COLOR=0xff000000              # Same as nvim bg
export BAR_BORDER_COLOR=0xff21252b       # bg1
export BACKGROUND_1=0xe6282c34           # Translucent nvim bg
export BACKGROUND_2=0xff21252b           # bg1
export ICON_COLOR=0xff5c6370             # grey
export LABEL_COLOR=0xffabb2bf            # fg
export POPUP_BACKGROUND_COLOR=0xf0282c34 # nvim bg
export POPUP_BORDER_COLOR=0xff61afef     # blue
export SHADOW_COLOR=0x80000000           # Soft shadow

# Accent colors - OneDark harmonious palette
export ACCENT_PRIMARY=0xff6CB6EB         # Blue
export ACCENT_SECONDARY=0xffA0C980       # Green
export ACCENT_TERTIARY=0xffF74C00       # Orange
export ACCENT_QUATERNARY=0xffD38AEA      # Purple
export ACCENT_PINK=0xffD38AEA            # Magenta
export ACCENT_TEAL=0xff5DBBC1            # Cyan
export ACCENT_GOLD=0xffDDB974            # Yellow

# Specialized UI colors
export SEPARATOR_COLOR=0x605c6370        # Subtle grey
export HOVER_BG=0x4021252b               # Hover bg1
export ACTIVE_BG=0x603e4451              # Active selection

# Popup/contrast colors
export POPUP_LABEL_COLOR=0xffabb2bf      # fg
export POPUP_ICON_COLOR=0xff5c6370       # grey
export CONTRAST_TEXT=0xffabb2bf          # fg
