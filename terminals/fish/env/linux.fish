neofetch

# Environment variables

# You may need to manually set your language environment
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

#Python
fish_add_path /usr/local/opt/python/libexec/bin:$PATH

# GOLANG
set -gx GOROOT=$HOME/go
set -gx PATH=$PATH:$GOROOT/bin

# OPEN SSL
fish_add_path "/usr/local/opt/openssl/bin:$PATH"

# Editor
set -gx EDITOR="nvim"
set -gx GIT_EDITOR="nvim"
set -gx REACT_EDITOR="nvim"

# Bat
set -gx BAT_THEME="TwoDark"

# Fzf
set -gx FZF_COMPLETION_TRIGGER='**'
set -gx FZF_DEFAULT_COMMAND='rg --files --hidden'
set -gx FZF_DEFAULT_OPTS='--height 90% --layout reverse --border --color "border:#b877db" --preview="bat --color=always {}"'

#Scripts
fish_add_path "$HOME/.config/scripts:$PATH"

#TLDR
set -gx TLDR_OS=linux
