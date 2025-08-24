#!/opt/homebrew/bin/bash

AEROSPACE="/opt/homebrew/bin/aerospace"

focus_window() {
  local direction=$1
  local window_ids=($($AEROSPACE list-windows --workspace focused --format '%{window-id}'))
  local window_count=${#window_ids[@]}

  if [[ $window_count -le 1 ]]; then
    exit 1
  fi

  local current_id=$($AEROSPACE list-windows --focused --format '%{window-id}')

  local current_index
  for i in "${!window_ids[@]}"; do
    if [[ "${window_ids[$i]}" == "$current_id" ]]; then
      current_index=$i
      break
    fi
  done

  local target_index
  case $direction in
    left|up)
      ((target_index = (current_index - 1 + window_count) % window_count))
      ;;
    right|down)
      ((target_index = (current_index + 1) % window_count))
      ;;
    *)
      exit 1
      ;;
  esac

  $AEROSPACE focus --window-id "${window_ids[$target_index]}"
}

if [[ $# -eq 1 ]]; then
  focus_window "$1"
else
  exit 1
fi
