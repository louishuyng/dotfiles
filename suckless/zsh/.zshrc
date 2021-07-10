# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# lazyload zsh - boost zsh startup time
source ~/.zsh-defer/zsh-defer.plugin.zsh
PS1="%F{12}%~%f "
RPS1="%F{240}Loading...%f"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Current theme         https://github.com/sindresorhus/pure
# How to install        npm install --global pure-prompt
zstyle :prompt:pure:path color white
zstyle ':prompt:pure:prompt:*' color green
zstyle :prompt:pure:git:stash show yes

export LC_ALL=en_US.UTF-8
zsh-defer source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
zsh-defer source ~/.zsh/zsh-completions/zsh-completions.plugin.zsh
zsh-defer source ~/.zsh/zsh-z/zsh-z.plugin.zsh
[ -f ~/.fzf.zsh ] && zsh-defer source ~/.fzf.zsh

#--------------------------------------------------
## EXPORTS
# Main PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh/
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=/usr/local/opt/python/libexec/bin:$PATH
export PATH=$PATH:/usr/local/mysql/bin
export PATH="$PATH:$HOME/development/flutter/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_HOME=/Users/ziik/Library/Android/sdk

# OPEN SSL
export PATH="/usr/local/opt/openssl/bin:$PATH"


## OH-MY_ZSH
source $ZSH/oh-my-zsh.sh

#--------------------------------------------------
## GIT CONFIG
GIT_AUTHOR_NAME="Louis"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="huynguyennbk@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"

#--------------------------------------------------
## ALIAS
# GNU
alias cat='bat'
alias nv="nvim"
alias c="clear"
alias rf='rm -rf'
alias sdn="osascript -e 'tell app \"System Events\" to shut down'"
alias conf='nv ~/.config'
alias ll="ls -l"
alias lla="ll -A"

# TOOLS
alias typeracer='cli-typer'
alias speedTest='speed-test'
alias ra='ranger'
alias tm='tmux  -u'

# GIT
alias gps='git push'
alias gp='git pull'
alias gpo='git pull origin'
alias gco='git checkout'

# APP OR WEB SHORTCUT
alias brave="open -a 'Brave Browser'"
alias facebook="open -a 'Brave Browser' http://www.facebook.com "
alias youtube="open -a 'Google Chrome' http://www.youtube.com "
alias netflix="open -a 'Brave Browser' http://www.netflix.com "
alias trello="open -a 'Trello'"
alias postman="open -a 'Postman'"

# LANGUAGES
# JS
alias rnm='rm  -rf node_modules'
alias npmi='npm install'
alias rnmai='rm -rf node_modules && yarn'
# RAILS
alias bdi='bundle install'
alias bdu='bundle update --bundler'

# DOCKER
alias dkcd="docker-compose down"
alias dkcu="docker-compose up"
alias dkcud="docker-compose up -d"
alias dpsa="docker ps -a"
alias dks="open -a 'Docker'"
alias dkc="killall Docker"

# REDIS
alias rds='brew services start redis'
alias rdc='brew services stop redis'

# NETWORK
alias wfscan='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan'
alias wfon='networksetup -setairportpower en0 on'
alias wfoff='networksetup -setairportpower en0 off'
alias wfjoin='networksetup -setairportnetwork en0'
alias wfi='networksetup -listallhardwareports'
alias localip='ifconfig | grep inet | grep broadcast | cut -d " " -f 2'

#--------------------------------------------------
## CUSTOM FUNCTIONS
#MAC
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

## DEV TOOLS
function Dev() {
  str="$*"
  tm new -s $str
}

function prettierGitDiff() {
  extension=$1;

  prettier --write '$(git diff --name-only | grep '.$extension' | xargs)'
}


# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# SSH add name
function sshadd() {
  name=$1;

  ssh-add -D

  if [ -z "${name}" ]; then
    ssh-add -K ~/.ssh/id_rsa
  else
    ssh-add -K ~/.ssh/id_rsa_$name
  fi
}

# Git clone + npm install
function gcn() {
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

#--------------------------------------------------
## OTHERS
# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# `Frozing' tty, so after any command terminal settings will be restored
ttyctl -f

# lazyload zsh - boost zsh startup time
PS1="%F{12}%~%f "
RPS1="%F{240}Loading...%f"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Peco History
source ~/.zsh/zsh-peco-history/zsh-peco-history.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval $(thefuck --alias)


# Load pure theme afterward
autoload -U promptinit; promptinit
prompt pure

zsh-defer -c 'RPS1="%F{240}%f"'
