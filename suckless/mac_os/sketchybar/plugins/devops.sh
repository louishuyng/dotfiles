#!/opt/homebrew/bin/bash

# Source colors for consistent theming
source "$CONFIG_DIR/colors.sh"

# Create a simple popup menu for the logo
sketchybar --set devops popup.drawing=toggle

# If already toggled, set icon color to grey
if [ "$(sketchybar --query devops | jq -r .popup.drawing)" = "on" ]; then
    sketchybar --set devops icon.color=$CYAN
else
    sketchybar --set devops icon.color=$GREY
fi


sketchybar --add item devops.kubernetes popup.devops \
  --set devops.kubernetes icon="󱃾" \
  icon.color=$BLUE \
  icon.font="JetbrainsMono Nerd Font Propo:Semibold:17.0" \
  label="Kubernetes" \
  click_script="open -a 'Lens'; sketchybar --set devops popup.drawing=off icon.color=$GREY"

sketchybar --add item devops.docker popup.devops \
           --set devops.docker icon="󰡨" \
                            icon.color=$BLUE \
                            icon.font="JetbrainsMono Nerd Font Propo:Semibold:20.0" \
                            label="Docker" \
                            click_script="open -a OrbStack; sketchybar --set devops popup.drawing=off icon.color=$GREY"


sketchybar --add item devops.datagrip popup.devops \
           --set devops.datagrip icon="" \
                            icon.color=$MAGENTA \
                            icon.font="JetbrainsMono Nerd Font Propo:Semibold:20.0" \
                            label="DataGrip" \
                            click_script="open -a DataGrip; sketchybar --set devops popup.drawing=off icon.color=$GREY"

sketchybar --add item devops.mongodb popup.devops \
            --set devops.mongodb icon="" \
                             icon.color=$GREEN \
                             icon.font="JetbrainsMono Nerd Font Propo:Semibold:18.0" \
                             icon.padding_right=12 \
                             icon.padding_left=7 \
                             label="MongoDB Compass" \
                             click_script="open -a 'MongoDB Compass'; sketchybar --set devops popup.drawing=off icon.color=$GREY"


sketchybar --add item devops.api popup.devops \
            --set devops.api icon="󱂛" \
                          icon.color=$YELLOW \
                          icon.font="JetbrainsMono Nerd Font Propo:Semibold:19.0" \
                          label="API" \
                          click_script="open -a Yaak; sketchybar --set devops popup.drawing=off icon.color=$GREY"

sketchybar --add item devops.git popup.devops \
            --set devops.git icon="" \
                          icon.color=$GREEN \
                          icon.font="JetbrainsMono Nerd Font Propo:Semibold:14.0" \
                          icon.padding_left=5 \
                          label="GitKraken" \
                          click_script="open -a 'GitKraken'; sketchybar --set devops popup.drawing=off icon.color=$GREY"
