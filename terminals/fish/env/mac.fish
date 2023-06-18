# Environment variables

# You may need to manually set your language environment
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

#Homebrew's sbin
fish_add_path /opt/homebrew/bin
fish_add_path /usr/local/sbin
#
# #Qutebrowser
fish_add_path /Applications/qutebrowser.app/Contents/MacOS
#
# #Fluter
fish_add_path $HOME/development/flutter/bin
#
# #Android
set -gx ANDROID_HOME ~/Library/Android/sdk
fish_add_path $HOME/Library/Android/sdk
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/tools
fish_add_path $ANDROID_HOME/tools/bin
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $HOME/.pub-cache/bin
#
# #SQL
fish_add_path /usr/local/mysql/bin
#
# #Python
fish_add_path /usr/local/opt/python/libexec/bin
#
# #JAVA
fish_add_path /usr/libexec/java_home
fish_add_path /opt/homebrew/opt/openjdk/bin
set -gx CPPFLAGS "-I/opt/homebrew/opt/openjdk/include"
#
# #Golang
set -gx GOROOT (go env GOROOT)
set -gx GOBIN  (go env GOBIN)
set -gx GOPATH $HOME/development/golib
set -gx GO111MODULE on
set -gx GOV $(asdf where golang)
set -gx GOROOT $GOV/go
fish_add_path $GOPATH/bin
fish_add_path $GOROOT/bin
fish_add_path $GOBIN

#
# # OPEN SSL
fish_add_path /usr/local/opt/openssl/bin
#
# # Prompt Config
set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/config.toml

# # Editor
set -gx EDITOR "nvim"
set -gx GIT_EDITOR "nvim"
set -gx REACT_EDITOR "nvim"

# # Fzf
set -gx FZF_COMPLETION_TRIGGER '**'
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden'
set -gx FZF_DEFAULT_OPTS '--height 90% --layout reverse --border --color "border:#b877db" --preview="bat --color=always {}"'

# #TLDR
set -gx TLDR_OS osx
#
set -gx DISABLE_SPRING true

# # Yabai
set -gx YABAI_CERT yabai-cert
#
# # Bat
set -gx BAT_THEME "TwoDark"

# #Rust
fish_add_path $HOME/.cargo/bin
#
# #GO
fish_add_path /usr/local/go/bin
#
# #Scripts
fish_add_path $HOME/.config/scripts

# # GNU sed
fish_add_path /usr/local/opt/gnu-sed/libexec/gnubin

# Emacs
fish_add_path ~/.emacs.d/bin/

# MacPort
fish_add_path /opt/local/bin 

# Webstorm Path
fish_add_path /Applications/WebStorm.app/Contents/MacOS

