### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
	print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
	command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
	command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
		print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
		print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# if [ -z "$TMUX" ]
# then
#     tmux attach -t work || tmux new -s work
# fi

zinit ice depth=1 atload"!source ~/.config/suckless/zsh/.p10k-evilball.zsh" lucid nocd
zinit light romkatv/powerlevel10k

# Oh-my-zsh plugins
zinit snippet OMZ::lib/history.zsh

zinit snippet OMZ::lib/key-bindings.zsh

zinit ice wait lucid
zinit snippet OMZ::lib/completion.zsh

zinit ice wait lucid
zinit snippet OMZ::lib/grep.zsh

# Oh-my-zsh plugins
zinit ice wait lucid atload"unalias grv"
zinit snippet OMZ::plugins/git/git.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/extract/extract.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/golang/golang.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/fzf/fzf.plugin.zsh

zinit ice wait lucid
zinit snippet OMZ::plugins/autojump/autojump.plugin.zsh

# Plugins
zinit ice depth=1 lucid
zinit light trystan2k/zsh-tab-title

zinit ice depth=1 wait lucid
zinit light Aloxaf/fzf-tab

zinit ice depth=1 wait blockf lucid atpull"zinit creinstall -q ."
zinit light clarketm/zsh-completions

zinit ice depth=1 wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zinit light zdharma/fast-syntax-highlighting

zinit ice depth=1 wait lucid compile"{src/*.zsh,src/strategies/*.zsh}" atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice depth=1 wait"1" lucid atinit"zstyle ':history-search-multi-word' page-size '20'"
zinit light zdharma/history-search-multi-word

zinit ice depth=1 wait"2" lucid
zinit light wfxr/forgit

zinit ice depth=1 wait"2" lucid
zinit light hlissner/zsh-autopair

zinit ice depth=1 wait"2" lucid
zinit light peterhurford/up.zsh

zinit ice depth=1 wait"2" lucid
zinit light MichaelAquilina/zsh-you-should-use

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
