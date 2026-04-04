# Environment variables
# Note: mise is activated in config.fish

# Auto-detect macOS appearance and apply matching theme
set -l _appearance (defaults read -g AppleInterfaceStyle 2>/dev/null)
if test "$_appearance" = "Dark"
    source ~/.dotfiles/terminals/fish/themes/catppuccin-mocha.fish
    set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/config.toml
else
    source ~/.dotfiles/terminals/fish/themes/catppuccin-latte.fish
    set -gx STARSHIP_CONFIG ~/.dotfiles/terminals/starship/catppuccin-latte.toml
end

# You may need to manually set your language environment
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

if test -n "$TMUX"
    set -gx TERM tmux-256color
else
    set -gx TERM xterm-256color
end

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
set -gx GOROOT (go env GOROOT 2>/dev/null)
set -gx GOBIN (go env GOBIN 2>/dev/null)
set -gx GOPATH $HOME/development/golib
set -gx GO111MODULE on
# Set GOV only if mise and golang are available
if command -q mise; and mise where go &>/dev/null
    set -gx GOV $(mise where go)
end
fish_add_path $GOPATH/bin
fish_add_path $GOROOT/bin
fish_add_path $GOBIN

#
# # OPEN SSL
fish_add_path /usr/local/opt/openssl/bin
#

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

# Duck DB
fish_add_path ~/.duckdb/cli/latest

# K8s etcd
fish_add_path ~/LX14/repository/github.com/louishuyng/kubernetes/third_party/etcd

set -gx GITHUB_TOKEN (cat ~/.github_token)
