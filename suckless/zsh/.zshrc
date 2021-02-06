export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh/
export TERM=xterm-256color

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
  zsh-autosuggestions
  zsh-completions
  vi-mode
)

autoload -U compinit && compinit

ZSH_THEME="spaceship"
SPACESHIP_PROMPT_ADD_NEWLINE="true"
SPACESHIP_CHAR_PREFIX='\ufbdf '
SPACESHIP_CHAR_PREFIX_COLOR='yellow'
SPACESHIP_CHAR_SUFFIX=(" ")
SPACESHIP_CHAR_COLOR_SUCCESS="yellow"
SPACESHIP_CHAR_SYMBOL='~'
SPACESHIP_PROMPT_DEFAULT_PREFIX="$USER"
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="true"
SPACESHIP_VENV_COLOR="magenta"
SPACESHIP_VENV_PREFIX="("
SPACESHIP_VENV_SUFFIX=")"
SPACESHIP_VENV_SYMBOL='\uf985'
SPACESHIP_USER_SHOW="true"
SPACESHIP_DOCKER_SYMBOL='\ue7b0'
SPACESHIP_DOCKER_VERBOSE='false'
SPACESHIP_BATTERY_SHOW='false'

source $ZSH/oh-my-zsh.sh

GIT_AUTHOR_NAME="Louis"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="huynguyennbk@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"

## ALIAS
alias cat='bat'
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
alias nv='~/.nvim/bin/nvim'
alias vimrc='nvim ~/.config/nvim/init.vim'
alias tm='tmux  -2'
alias rf='rm -rf'
alias spotify='/usr/local/lib/node_modules/spotify-cli-mac/./index.js'
alias sp='/usr/local/lib/node_modules/spotify-cli-mac/./index.js'
alias gpj='cd ~/DevLife/Project/'
alias typeracer='cli-typer'
alias speedTest='speed-test'
alias ra='ranger'
alias matrix='source ~/.matrix.sh'
alias letwork='~/.letwork.sh'
alias rni='rm  -rf node_modules && yarn && npx pod-install'

#Wifi
alias wfscan='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan'
alias wfon='networksetup -setairportpower en0 on'
alias wfoff='networksetup -setairportpower en0 off'
alias wfjoin='networksetup -setairportnetwork en0'
alias wfi='networksetup -listallhardwareports'

#Mac
#
function b64() {
  cat $1 | base64 | pbcopy;
}

function br() {
  str="$*"
  brightness $str
}

function work() {
  name="$1"

  nv ~/Dev/Projects/$1
}

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

function Dev() {
  str="$*"
  tm new -s $str
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

function sshadd() {
  name=$1;

  ssh-add -D

  if [ -z "${name}" ]; then
    ssh-add -K ~/.ssh/id_rsa
  else
    ssh-add -K ~/.ssh/id_rsa_$name
  fi
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

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin:$HOME/development/flutter/bin"
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_HOME=/Users/ziik/Library/Android/sdk

alias vim="stty stop '' -ixoff ; vim"
# `Frozing' tty, so after any command terminal settings will be restored
ttyctl -f

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=/usr/local/opt/python/libexec/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH=$PATH:/usr/local/mysql/bin
alias pip=/usr/local/bin/pip3

export NVM_DIR="/Users/ziik/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/louis/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/louis/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/louis/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/louis/google-cloud-sdk/completion.zsh.inc'; fi

# KUBECONTEXT
# Show current context in kubectl.
spaceship_kubecontext() {
  [[ $SPACESHIP_KUBECONTEXT_SHOW == false ]] && return

  # Show KUBECONTEXT status only for folders with .kube and file config inside.
  [[ -f .kube/config ]] || return

  local kube_context=$(awk -F' *: *' '$1 == "current-context" {print $2}' ~/.kube/config)

  _prompt_section \
    "$SPACESHIP_KUBECONTEXT_COLOR" \
    "$SPACESHIP_KUBECONTEXT_PREFIX" \
    "${SPACESHIP_KUBECONTEXT_SYMBOL}${kube_context}" \
    "$SPACESHIP_KUBECONTEXT_SUFFIX"
}
export PATH="/usr/local/sbin:$PATH"
