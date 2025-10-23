# Environment variables
# Note: asdf shims are added in config.fish

# You may need to manually set your language environment
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

set -gx TERM xterm-256color

#Homebrew's sbin
fish_add_path /opt/homebrew/bin
fish_add_path /usr/local/sbin
fish_add_path /opt/homebrew/sbin
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
set -gx CPPFLAGS -I/opt/homebrew/opt/openjdk/include
#
# #Golang
set -gx GOROOT
set -gx GOBIN $(go env GOBIN 2>/dev/null)
set -gx GOPATH $HOME/development/golib
set -gx GO111MODULE on
# Set GOV only if asdf and golang are available
if command -q asdf; and asdf current golang &>/dev/null
    set -gx GOV $(asdf where golang)
end
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
set -gx EDITOR nvim
set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
set -gx GIT_EDITOR nvim
set -gx REACT_EDITOR nvim

# # Fzf
set -gx FZF_COMPLETION_TRIGGER '**'
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden'
set -gx FZF_DEFAULT_OPTS '--layout reverse --preview="bat --color=always {}" --preview-window="up,60%,border-bottom,+{2}+3/3,~3"'

# #TLDR
set -gx TLDR_OS osx
#
set -gx DISABLE_SPRING true

# # Yabai
set -gx YABAI_CERT yabai-cert
#
# # Bat
set -gx BAT_THEME TwoDark

# #Rust
fish_add_path $HOME/.cargo/bin
#
# #GO
fish_add_path /usr/local/go/bin

# # ROR
set -gx BUNDLE_EDITOR nvim
unset GEM_HOME

# #Scripts
fish_add_path $HOME/.config/scripts

# # GNU sed
fish_add_path /usr/local/opt/gnu-sed/libexec/gnubin

# Emacs
fish_add_path ~/.emacs.d/bin/
fish_add_path ~/.config/emacs/bin

# MacPort
fish_add_path /opt/local/bin

# Webstorm Path
fish_add_path /Applications/WebStorm.app/Contents/MacOS

# Postgres Lib
fish_add_path /opt/homebrew/opt/libpq/bin/pg_restore

# Wezterm
fish_add_path /Applications/WezTerm.app/Contents/MacOS

# Vault
set -gx VAULT_ADDR http://127.0.0.1:8200

# Ghostty
fish_add_path SNACKS_GHOSTTY=true

# Terraform
set -gx TFENV_ARCH arm64
