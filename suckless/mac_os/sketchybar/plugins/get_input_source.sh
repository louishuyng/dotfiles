#!/opt/homebrew/bin/bash

SOURCE=$(im-select)

# Read the plist data
case ${SOURCE} in
'com.apple.keylayout.ABC') ICON='en' ;;
'com.apple.inputmethod.VietnameseIM.VietnameseTelex') ICON='vi' ;;
'com.apple.inputmethod.VietnameseIM.VietnameseSimpleTelex') ICON='vi' ;;
esac


sketchybar --set $NAME icon="$ICON"
