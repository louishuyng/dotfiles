set PATH $HOME/bin:/usr/local/bin:$PATH

set fish_greeting ""
set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias c "clear"
command -qv nvim && alias vim nvim

alias cat "bat"
alias nv "nvim"
alias dcpd "docker-compose down"
alias dcpu "docker-compose up"

#Docker
alias dpsa "docker ps -a"
alias dcup "docker-compose up"
alias dcupd "docker-compose up -d"

alias vimrc "nvim ~/.config/nvim/init.vim"
alias tm "tmux  -2"

alias ra "ranger"
alias nvconf "cd ~/.config/nvim && nv"

#Wifi
alias speedTest "speed-test"
alias wfscan "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan"
alias wfon "networksetup -setairportpower en0 on"
alias wfoff "networksetup -setairportpower en0 off"
alias wfjoin "networksetup -setairportnetwork en0"
alias wfi "networksetup -listallhardwareports"

#Network
alias localip "ifconfig | grep inet | grep broadcast | cut -d ' ' -f 2"

#GIT
alias gps "git push"
alias gp "git pull"
alias gco "git checkout"

alias vim "stty stop '' -ixoff ; vim"
alias pip "/usr/local/bin/pip3"

set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

# NVM
function __check_rvm --on-variable PWD --description 'Do nvm stuff'
  status --is-command-substitution; and return

  if test -f .nvmrc; and test -r .nvmrc;
    nvm use
  else
  end
end

switch (uname)
  case Darwin
    source (dirname (status --current-filename))/config-osx.fish
  case Linux
    # Do nothing
  case '*'
    source (dirname (status --current-filename))/config-windows.fish
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end
