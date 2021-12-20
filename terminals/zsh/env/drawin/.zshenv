# Enviroment variables

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#Homebrew's sbin
export PATH="/usr/local/sbin:$PATH"

#Qutebrowser
export PATH=$PATH:/Applications/qutebrowser.app/Contents/MacOS

#Fluter
export PATH=$PATH:$HOME/development/flutter/bin

#Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/.pub-cache/bin

#SQL
export PATH=$PATH:/usr/local/mysql/bin

#Python
export PATH=/usr/local/opt/python/libexec/bin:$PATH

#JAVA
export JAVA_HOME=$(/usr/libexec/java_home)

#Golang
export GO111MODULE=off

export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin

export GOPATH=$HOME/development/golib
export PATH=$PATH:$GOPATH/bin
export GOPATH=$GOPATH:$HOME/Dev/Projects/Golang

# OPEN SSL
export PATH="/usr/local/opt/openssl/bin:$PATH"

# Editor
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export REACT_EDITOR="nvim"

# Yabai
export YABAI_CERT=yabai-cert

# Bat
export BAT_THEME="TwoDark"

# Fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS='--height 90% --layout reverse --border --color "border:#b877db" --preview="bat --color=always {}"'

#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#Rust
export PATH=$PATH:$HOME/.cargo/bin

#GO
export PATH=$PATH:/usr/local/go/bin

#Scripts
export PATH="$HOME/.config/scripts:$PATH"

#TLDR
export TLDR_OS=osx
