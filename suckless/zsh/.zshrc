source ~/.zsh-defer/zsh-defer.plugin.zsh

PS1="%F{12}%~%f "
RPS1="%F{240}Loading...%f"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

### Theme
zstyle :prompt:pure:path color white
zstyle ':prompt:pure:prompt:*' color green
zstyle :prompt:pure:git:stash show yes

### Hightlight 
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

zsh-defer zinit light agkozak/zsh-z
zsh-defer zinit light djui/alias-tips
zsh-defer zinit light jimeh/zsh-peco-history
zsh-defer zinit light zsh-users/zsh-autosuggestions
zsh-defer zinit light zsh-users/zsh-completions
zsh-defer zinit light zsh-users/zsh-syntax-highlighting

# Load Env
export PATH="$PATH:$HOME/.rvm/bin"
export PATH=/usr/local/sbin:$PATH
source "$HOME/.config/suckless/zsh/.zshenv"

alias luamake=/Users/admin/.config/nvim/lua-language-server/3rd/luamake/luamake

### Alias
source "$HOME/.config/suckless/zsh/alias/app.zsh"
source "$HOME/.config/suckless/zsh/alias/docker.zsh"
source "$HOME/.config/suckless/zsh/alias/general.zsh"
source "$HOME/.config/suckless/zsh/alias/git.zsh"
source "$HOME/.config/suckless/zsh/alias/k8s.zsh"
source "$HOME/.config/suckless/zsh/alias/languages.zsh"
source "$HOME/.config/suckless/zsh/alias/network.zsh"
source "$HOME/.config/suckless/zsh/alias/os.zsh"
source "$HOME/.config/suckless/zsh/alias/redis.zsh"
source "$HOME/.config/suckless/zsh/alias/spotify.zsh"
source "$HOME/.config/suckless/zsh/alias/tmux.zsh"
source "$HOME/.config/suckless/zsh/alias/tools.zsh"

### Functions
source "$HOME/.config/suckless/zsh/functions/general.zsh"
source "$HOME/.config/suckless/zsh/functions/git.zsh"
source "$HOME/.config/suckless/zsh/functions/k8s.zsh"
source "$HOME/.config/suckless/zsh/functions/tmux.zsh"
source "$HOME/.config/suckless/zsh/functions/vpn.zsh"

### Load pure theme afterward
autoload -U promptinit; promptinit
prompt pure
zsh-defer -c 'RPS1="%F{240}%f"'

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk

(wal -r &)
