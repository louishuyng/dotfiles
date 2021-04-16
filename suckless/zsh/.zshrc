export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh/
export TERM=xterm-256color

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

# Hightlight syntax for manual page
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

export LC_ALL=en_US.UTF-8
zsh-defer source ~/.config/suckless/zsh/z.sh
zsh-defer source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
zsh-defer source ~/.zsh/zsh-completions/zsh-completions.plugin.zs
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

GIT_AUTHOR_NAME="Louis"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="huynguyennbk@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"

## ALIAS
alias cat='bat'
alias fuck="git"
alias nv="nvim"
alias c="clear"
alias ez="vi $HOME/.zshrc"
alias server="python -m SimpleHTTPServer"
alias socks="ssh -vND 8888 kim"
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
alias sdn="osascript -e 'tell app \"System Events\" to shut down'"
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
alias nvconf="cd ~/.config/nvim && nv"

#Docker
alias dkcd="docker-compose down"
alias dkcu="docker-compose up"
alias dkcud="docker-compose up -d"
alias dpsa="docker ps -a"
alias dks="open -a 'Docker'"
alias dkc="killall Docker"

#Wifi
alias wfscan='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport scan'
alias wfon='networksetup -setairportpower en0 on'
alias wfoff='networksetup -setairportpower en0 off'
alias wfjoin='networksetup -setairportnetwork en0'
alias wfi='networksetup -listallhardwareports'

#Network
alias localip='ifconfig | grep inet | grep broadcast | cut -d " " -f 2'

#GIT
alias gps='git push'
alias gp='git pull'
alias gco='git checkout'

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

export PATH=$PATH:/usr/local/mysql/bin
alias pip=/usr/local/bin/pip3

export NVM_DIR="/Users/ziik/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Load pure theme afterward
autoload -U promptinit; promptinit
prompt pure

zsh-defer -c 'RPS1="%F{240}%f"'
export PATH="/usr/local/opt/openssl/bin:$PATH"
