#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Create a simple popup menu for the logo
sketchybar --set devops popup.drawing=toggle

sketchybar --add item devops.docker popup.devops \
           --set devops.docker icon="" \
                            icon.color=$PURPLE \
                            label="DataGrip" \
                            click_script="open -a DataGrip; sketchybar --set devops popup.drawing=off"

sketchybar --add item devops.kubernetes popup.devops \
            --set devops.kubernetes icon="󱃾" \
                              icon.color=$BLUE \
                              label="Kubernetes" \
                              click_script="open -a 'Lens'; sketchybar --set devops popup.drawing=off"

sketchybar --add item devops.mongodb popup.devops \
            --set devops.mongodb icon="" \
                             icon.color=$GREEN \
                             label="MongoDB Compass" \
                             click_script="open -a 'MongoDB Compass'; sketchybar --set devops popup.drawing=off"


sketchybar --add item devops.api popup.devops \
            --set devops.api icon="󱂛" \
                          icon.color=$YELLOW \
                          label="API" \
                          click_script="open -a Yaak; sketchybar --set devops popup.drawing=off"

sketchybar --add item devops.git popup.devops \
            --set devops.git icon="" \
                          icon.color=$GREEN \
                          label="GitKraken" \
                          click_script="open -a 'GitKraken'; sketchybar --set devops popup.drawing=off"
