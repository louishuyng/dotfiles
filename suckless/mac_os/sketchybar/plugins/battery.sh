#!/opt/homebrew/bin/bash

# Braille patterns for battery visualization
declare -a dots_0=("⠀")
declare -a dots_1=("⠁" "⠂" "⠄" "⠈" "⠐" "⠠" "⡀" "⢀")
declare -a dots_2=("⠃" "⠅" "⠆" "⠉" "⠊" "⠌" "⠑" "⠒" "⠔" "⠘" "⠡" "⠢" "⠤" "⠨" "⠰" "⡁" "⡂" "⡄" "⡈" "⡐" "⡠" "⢁" "⢂" "⢄" "⢈" "⢐" "⢠" "⣀")
declare -a dots_3=("⠇" "⠋" "⠍" "⠎" "⠓" "⠕" "⠖" "⠙" "⠚" "⠜" "⠣" "⠥" "⠦" "⠩" "⠪" "⠬" "⠱" "⠲" "⠴" "⠸" "⡃" "⡅" "⡆" "⡉" "⡊" "⡌" "⡑" "⡒" "⡔" "⡘" "⡡" "⡢" "⡤" "⡨" "⡰" "⢃" "⢅" "⢆" "⢉" "⢊" "⢌" "⢑" "⢒" "⢔" "⢘" "⢡" "⢢" "⢤" "⢨" "⢰" "⣁" "⣂" "⣄" "⣈" "⣐" "⣠")
declare -a dots_4=("⠏" "⠗" "⠛" "⠝" "⠞" "⠧" "⠫" "⠭" "⠮" "⠳" "⠵" "⠶" "⠹" "⠺" "⠼" "⡇" "⡋" "⡍" "⡎" "⡓" "⡕" "⡖" "⡙" "⡚" "⡜" "⡣" "⡥" "⡦" "⡩" "⡪" "⡬" "⡱" "⡲" "⡴" "⡸" "⢇" "⢋" "⢍" "⢎" "⢓" "⢕" "⢖" "⢙" "⢚" "⢜" "⢣" "⢥" "⢦" "⢩" "⢪" "⢬" "⢱" "⢲" "⢴" "⢸" "⣃" "⣅" "⣆" "⣉" "⣊" "⣌" "⣑" "⣒" "⣔" "⣘" "⣡" "⣢" "⣤" "⣨" "⣰")
declare -a dots_5=("⠟" "⠯" "⠷" "⠻" "⠽" "⠾" "⡏" "⡗" "⡛" "⡝" "⡞" "⡧" "⡫" "⡭" "⡮" "⡳" "⡵" "⡶" "⡹" "⡺" "⡼" "⢏" "⢗" "⢛" "⢝" "⢞" "⢧" "⢫" "⢭" "⢮" "⢳" "⢵" "⢶" "⢹" "⢺" "⢼" "⣇" "⣋" "⣍" "⣎" "⣓" "⣕" "⣖" "⣙" "⣚" "⣜" "⣣" "⣥" "⣦" "⣩" "⣪" "⣬" "⣱" "⣲" "⣴" "⣸")
declare -a dots_6=("⠿" "⡟" "⡯" "⡷" "⡻" "⡽" "⡾" "⢟" "⢯" "⢷" "⢻" "⢽" "⢾" "⣏" "⣗" "⣛" "⣝" "⣞" "⣧" "⣫" "⣭" "⣮" "⣳" "⣵" "⣶" "⣹" "⣺" "⣼")
declare -a dots_7=("⡿" "⢿" "⣟" "⣯" "⣷" "⣻" "⣽" "⣾")
declare -a dots_8=("⣿")

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ $PERCENTAGE -eq 0 ]]; then
    arr_name="dots_0"
elif [[ $PERCENTAGE -le 12 ]]; then
    arr_name="dots_1"
elif [[ $PERCENTAGE -le 25 ]]; then
    arr_name="dots_2"
elif [[ $PERCENTAGE -le 37 ]]; then
    arr_name="dots_3"
elif [[ $PERCENTAGE -le 50 ]]; then
    arr_name="dots_4"
elif [[ $PERCENTAGE -le 62 ]]; then
    arr_name="dots_5"
elif [[ $PERCENTAGE -le 75 ]]; then
    arr_name="dots_6"
elif [[ $PERCENTAGE -le 87 ]]; then
    arr_name="dots_7"
else
    arr_name="dots_8"
fi

declare -n arr="$arr_name"
random_index=$((RANDOM % ${#arr[@]}))
ICON="${arr[$random_index]}"

if [[ $CHARGING != "" ]]; then
    LABEL=$(printf "%3d*" "$PERCENTAGE")
else
    LABEL=$(printf "%3d%%" "$PERCENTAGE")
fi

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
