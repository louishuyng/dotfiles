# Enviroment variables

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#Python
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# GOLANG
export GOROOT=$HOME/go
export PATH=$PATH:$GOROOT/bin

# OPEN SSL
export PATH="/usr/local/opt/openssl/bin:$PATH"

# Editor
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export REACT_EDITOR="nvim"

# Bat
export BAT_THEME="TwoDark"

# Fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS='--height 90% --layout reverse --border --color "border:#b877db" --preview="bat --color=always {}"'

#Scripts
export PATH="$HOME/.config/scripts:$PATH"

#TLDR
export TLDR_OS=linux
