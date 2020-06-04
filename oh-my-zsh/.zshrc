export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh/

plugins=(
  git
  colorize
  github
  jira
  vagrant
  virtualenv
  pip
  python
  brew
  osx
  zsh-syntax-highlighting
  docker
  zsh-autosuggestions
  zsh-completions
  vi-mode
)
autoload -U compinit && compinit

ZSH_THEME="daivasmara"

source $ZSH/oh-my-zsh.sh

GIT_AUTHOR_NAME="Louis"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="huynguyennbk@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"

## ALIAS
alias fuck="git"
alias dcpd="docker-compose down"
alias dcpu="docker-compose up"
alias c="clear"
alias ez="vi $HOME/.zshrc"
alias server="python -m SimpleHTTPServer"
alias socks="ssh -vND 8888 kim"
alias dpsa="docker ps -a"
alias dcup="docker-compose up"
alias dcupd="docker-compose up -d"
alias brave="open -a 'Brave Browser'"
alias facebook="open -a 'Brave Browser' http://www.facebook.com "
alias netflix="open -a 'Brave Browser' http://www.netflix.com "
alias trello="open -a 'Trello'"
alias genymotion="open -a 'Genymotion'"
alias postman="open -a 'Postman'"
alias skype="open -a 'Skype'"
alias slack="open -a 'Slack'"
alias postman="open -a 'Postman'"
alias chatwork="open -a 'Google Chrome' http://www.chatwork.com "
alias youtube="open -a 'Google Chrome' http://www.youtube.com "
alias dk="open -a 'Docker'"
alias sdn="osascript -e 'tell app \"System Events\" to shut down'"
alias nv='nvim'
alias vimrc='nvim ~/.config/nvim/init.vim'
alias tm='tmux'
alias rf='rm -rf'
alias spotify='/usr/local/lib/node_modules/spotify-cli-mac/./index.js'
alias sp='/usr/local/lib/node_modules/spotify-cli-mac/./index.js'
alias gpj='cd ~/DevLife/Project/'
alias typeracer='cli-typer'
alias speedTest='speed-test'
alias ra='ranger'
alias dev='tm new -s HACKER1 \; split-window -h -p 25 \;'
alias matrix='source ~/.matrix.sh'

#Wifi
alias wfscan='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan'
alias wfon='networksetup -setairportpower en0 on'
alias wfoff='networksetup -setairportpower en0 off'
alias wfjoin='networksetup -setairportnetwork en0'
alias wfi='networksetup -listallhardwareports'

function gg() {
  str="$*"
  open -a 'Brave Browser' 'https://www.google.com/search?q='$str
}

function yt() {
  str="$*"
  open -a 'Brave Browser' 'https://www.youtube.com/results?search_query='$str
}

function sd() {
  sudo shutdown -h +$*
}


# Node.JS
#export PATH="$PATH:`yarn global bin`"

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'


## CUSTOM FUNCTIONS

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}
function mdt() {
    markdown "$*" | lynx -stdin
}

function mdb() {
    local TMPFILE=$(mktemp)
    markdown "$*" > $TMPFILE && ( xdg-open $TMPFILE > /dev/null 2>&1 & )
}
# Git clone + npm install
function gcn {
    url=$1;
    if [ -n "${1}" ]; then
        echo 'OK'
    else
        echo 'Koooooooooooooooo'
    fi
    cd ~/code;
    reponame=$(echo $url | awk -F/ '{print $NF}' | sed -e 's/.git$//');
    git clone $url $reponame;
    cd $reponame;
    npm install;
}
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin:$HOME/development/flutter/bin"
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_HOME=/Users/ziik/Library/Android/sdk

alias vim="stty stop '' -ixoff ; vim"
# `Frozing' tty, so after any command terminal settings will be restored
ttyctl -f
SPACESHIP_PROMPT_ORDER=(
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  elixir        # Elixir section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  php           # PHP section
  rust          # Rust section
  haskell       # Haskell Stack section
  julia         # Julia section
  docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  dotnet        # .NET section
  ember         # Ember.js section
  kubecontext   # Kubectl context section
  terraform     # Terraform workspace section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

SPACESHIP_DOCKER_SHOW=true
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/.pub-cache/bin

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH=$PATH:/usr/local/mysql/bin
alias python=/usr/local/bin/python3.7
alias pip=/usr/local/bin/pip3

export NVM_DIR="/Users/ziik/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
