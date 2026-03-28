# Environment variables
# Note: mise is activated in .zshrc

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ -n "$TMUX" ]; then
    export TERM=tmux-256color
else
    export TERM=xterm-256color
fi

# Homebrew's sbin
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

# Qutebrowser
export PATH="/Applications/qutebrowser.app/Contents/MacOS:$PATH"

# Flutter
export PATH="$HOME/development/flutter/bin:$PATH"

# Android
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$HOME/Library/Android/sdk:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/tools:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"

# SQL
export PATH="/usr/local/mysql/bin:$PATH"

# Python
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# JAVA
export PATH="/usr/libexec/java_home:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# Golang
export GOROOT=$(go env GOROOT 2>/dev/null)
export GOBIN=$(go env GOBIN 2>/dev/null)
export GOPATH=$HOME/development/golib
export GO111MODULE=on
# Set GOV only if mise and golang are available
if command -v mise &>/dev/null && mise where go &>/dev/null 2>&1; then
    export GOV=$(mise where go)
fi
export PATH="$GOPATH/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOBIN:$PATH"

# OPEN SSL
export PATH="/usr/local/opt/openssl/bin:$PATH"

# Prompt Config
export STARSHIP_CONFIG=~/.dotfiles/terminals/starship/config.toml

# Editor
export EDITOR=nvim
export GIT_EDITOR=nvim
export REACT_EDITOR=nvim

# Fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS='--layout reverse --preview="bat --color=always {}" --preview-window="up,60%,border-bottom,+{2}+3/3,~3"'

# TLDR
export TLDR_OS=osx

export DISABLE_SPRING=true

# Yabai
export YABAI_CERT=yabai-cert

# Bat
export BAT_THEME=TwoDark

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# GO
export PATH="/usr/local/go/bin:$PATH"

# ROR
export BUNDLE_EDITOR=nvim
unset GEM_HOME

# Scripts
export PATH="$HOME/.config/scripts:$PATH"

# GNU sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

# Emacs
export PATH="$HOME/.emacs.d/bin/:$PATH"
export PATH="$HOME/.config/emacs/bin:$PATH"

# MacPort
export PATH="/opt/local/bin:$PATH"

# Webstorm Path
export PATH="/Applications/WebStorm.app/Contents/MacOS:$PATH"

# Postgres Lib
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Wezterm
export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"

# Vault
export VAULT_ADDR=http://127.0.0.1:8200

# Ghostty
export SNACKS_GHOSTTY=true

# Terraform
export TFENV_ARCH=arm64

# Duck DB
export PATH="$HOME/.duckdb/cli/latest:$PATH"

# K8s etcd
export PATH="$HOME/LX14/repository/github.com/louishuyng/kubernetes/third_party/etcd:$PATH"

export GITHUB_TOKEN=$(cat ~/.github_token 2>/dev/null)

# Doom Emacs configuration
export DOOMDIR="$HOME/.doom.d"

# Spicetify
export PATH="$HOME/.spicetify:$PATH"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# local bin
export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Coursier
export PATH="$PATH:$HOME/Library/Application Support/Coursier/bin"
