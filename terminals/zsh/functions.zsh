# ── Utility Functions ─────────────────────────────────────────────────────────

# base64 a file and copy to clipboard
b64() {
  cat "$1" | base64 | pbcopy
}

# Copy Figma Resources to Target Folder
cp_figma() {
  local target_folder="$1"
  mv ~/Downloads/Figma\ Resources/* "$target_folder"
}

# Run Devops Container Efficiently
devops() {
  local context="$1"
  echo "Running on Context: $context"
  echo "Running services: ${@:2}"
  docker-compose -f ~/.dotfiles/devops/docker-compose-$1.yaml up "${@:2}"
}

# Get the value associated with a key in a k/v paired list
dict_get() {
  local key="$1"
  shift
  test $# -gt 1 || return 1
  local args=("$@")
  local total=${#args[@]}
  for ((idx=0; idx<total; idx+=2)); do
    if test "$key" = "${args[$idx]}"; then
      echo "${args[$((idx+1))]}"
      return
    fi
  done
  return 1
}

# Print keys from a key/value paired list
dict_keys() {
  local args=("$@")
  for ((idx=0; idx<${#args[@]}; idx+=2)); do
    echo "${args[$idx]}"
  done
}

# Print values from a key/value paired list
dict_values() {
  local args=("$@")
  for ((idx=1; idx<${#args[@]}; idx+=2)); do
    echo "${args[$idx]}"
  done
}

# Stops the docker-compose service by name
docker-compose-down() {
  local service_name="$1"
  local service_path=$(cat ~/.dotfiles/config/docker-compose/name-to-path.txt | grep "$service_name" | awk '{print $2}')
  service_path=$(echo "$service_path" | sed "s|~|/Users/$USER|")
  docker-compose -f "$service_path" down
}

# Starts the docker-compose service by name
docker-compose-up() {
  local service_name="$1"
  local service_path=$(cat ~/.dotfiles/config/docker-compose/name-to-path.txt | grep "$service_name" | awk '{print $2}')
  service_path=$(echo "$service_path" | sed "s|~|/Users/$USER|")
  docker-compose -f "$service_path" up -d
}

# Focus mode via gum + sketchybar
focus() {
  local LIST_OPTIONS=(
    " craft"
    "󰮡 research"
    "󱢊 relaxing"
    " deep-work"
    " meeting"
    " break"
    " plan"
  )
  local FOCUS_SELECTION=$(printf "%s\n" "${LIST_OPTIONS[@]}" | gum choose \
    --header "🎯 What are you focusing on?")

  if [ -n "$FOCUS_SELECTION" ]; then
    local FOCUS_ICON=$(echo "$FOCUS_SELECTION" | cut -c1)
    local FOCUS_TEXT=$(echo "$FOCUS_SELECTION" | cut -d' ' -f2-)
    sketchybar --set focus icon="$FOCUS_ICON" label="$FOCUS_TEXT"
  else
    sketchybar --set focus icon="" label="void"
  fi
}

# Just commit fast without caring about hooks
fuck() {
  git add .
  local commit_message
  case "$1" in
    ci)      commit_message="chore: ci update" ;;
    bug)     commit_message="chore: fix small bug" ;;
    changes) commit_message="chore: small changes" ;;
    typo)    commit_message="chore: fix typo" ;;
    syntax)  commit_message="chore: fix syntax" ;;
  esac
  git commit -m "$commit_message" --no-verify
  git push origin HEAD
}

# New git branch regask style
gbre() {
  local TYPE="REG"
  local TICKET="$1"

  if [ -z "$TICKET" ]; then
    TICKET=$(gum input --placeholder "Jira Ticket number (If no ticket it will generate XXXX instead)")
  fi

  local DESCRIPTION=$(gum input --placeholder "Short description of the ticket" | tr '[:upper:]' '[:lower:]' | sed 's/ *$//' | tr ' ' '-')

  if [ -z "$TICKET" ]; then
    git checkout -b "$TYPE-XXXX-$DESCRIPTION"
  else
    git checkout -b "$TYPE-$TICKET-$DESCRIPTION"
  fi
}

# Git commit using gum for joyful interaction
gcm() {
  local TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
  local SCOPE=$(gum input --placeholder "scope")

  if [ -n "$SCOPE" ]; then
    SCOPE="($SCOPE)"
  fi

  local SUMMARY=$(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
  local DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

  git commit -m "$SUMMARY" -m "$DESCRIPTION"
}

# Git commit regask style (extracts ticket from branch name)
gcre() {
  local TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")

  local TICKET=$(git rev-parse --abbrev-ref HEAD | grep -oE '[A-Z]+-[0-9A-Z]+' | tail -n 1)
  if [ -n "$TICKET" ]; then
    TICKET="[$TICKET]"
  fi

  local SUMMARY=$(gum input --value "$TYPE: $TICKET " --placeholder "Summary of this change")
  local DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

  git commit -m "$SUMMARY" -m "$DESCRIPTION"
}

# cd to lib real path
goto() {
  local path=$(realpath $(which "$1") | awk 'sub(/\/[a-z]*$/, "", $0)')
  cd "$path"
}

# Unwip most recent WIP commit
gunwip() {
  git rev-list --max-count=1 --format="%s" HEAD | grep -q -- "--wip--" && git reset HEAD~1
}

# Unwip all WIP commits
gunwipall() {
  local commit=$(git log --grep="--wip--" --invert-grep --max-count=1 --format=format:"%H")
  if [ "$commit" != "$(git rev-parse HEAD)" ]; then
    git reset "$commit" || return 1
  fi
}

# WIP commit
gwip() {
  git add -A
  git rm $(git ls-files --deleted) 2>/dev/null
  git commit -m "--wip-- [skip ci]" --no-verify --no-gpg-sign
}

# Get kubernetes environment of one service
k_env() {
  local service="$1"
  local namespace="$2"
  k exec $(kubectl get pods -o=name --namespace "$namespace" | grep "pod/$service" | awk -F / '{print $2}') --namespace "$namespace" -- env | pbcopy
}

# k9s wrapper with dark/light theme switching
k7s() {
  local K9S_CONFIG_DIR="/Users/louishuyng/Library/Application Support/k9s/skins"
  local current_dir=$(pwd)

  cd "$K9S_CONFIG_DIR"

  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
    ln -sf skin-dark.yaml skin.yaml
  else
    ln -sf skin-light.yaml skin.yaml
  fi

  cd "$current_dir"
  k9s "$@"
}

# New tmux working space
new-ws() {
  p-clean
  tx start regask-devops
  tx start regask
  tx start personal
}

# Clean all major processes
p-clean() {
  local array=(node ruby k9s nvim gopls claude prettierd opencode)

  for element in "${array[@]}"; do
    if pkill -9 -f "$element" >/dev/null 2>&1; then
      echo "Successfully killed $element"
    else
      echo "No running $element processes"
    fi
  done

  brew services stop postgresql@15
  echo "Successfully stopped postgresql@15"
}

# Connect postgres locally using pgcli
pg-c() {
  local host="$1"
  local database="$2"

  if [ -z "$host" ]; then
    pgcli -h localhost -p 5432 -U postgres
  elif [ -z "$database" ]; then
    pgcli -h localhost -p 5432 -U "$host"
  else
    pgcli -h localhost -p 5432 -U "$host" "$database"
  fi
}

# tmux capture logging
tm-cap() {
  tmux capture-pane -pS -1000000 > /tmp/tmux_$(date +%Y%m%d_%H%M%S)
  nvim '+$' /tmp/$(/bin/ls -t /tmp | grep tmux | head -1)
}

# Open latest tmux capture log
tm-logger() {
  nvim '+$' /tmp/$(/bin/ls -t /tmp | grep tmux | head -1)
}

# Use nix shell for a specific project
use-nix() {
  nix-shell ~/.dotfiles/nix/$1.conf
}

# kubeswitch wrapper (same as fish `function s --wraps switcher`)
s() {
  kubeswitch "$@"
}

# ── Key Bindings (fish_user_key_bindings equivalent) ──────────────────────────

# Edit current command line in nvim (like fish's edit_command_buffer)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

# Clear screen and open nvim (Ctrl+N)
_clear_and_nvim() { clear; nvim; zle reset-prompt }
zle -N _clear_and_nvim
bindkey '^N' _clear_and_nvim

# Yazi (Ctrl+Y)
_open_yazi() { yazi; zle reset-prompt }
zle -N _open_yazi
bindkey '^Y' _open_yazi

# Atuin (Ctrl+R) — atuin init sets this up, but explicit fallback
bindkey '^R' _atuin_search 2>/dev/null || true

# fzf bindings (matches fish: --directory=^F --git_log=^G --process=^P --git_status=^S)
# These are set up by fzf's zsh integration loaded below
