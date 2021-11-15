### Load ENV
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
            print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

export PATH="$PATH:$HOME/.rvm/bin"
export PATH=/usr/local/sbin:$PATH
source "$HOME/.config/suckless/zsh/.zshenv"

alias luamake=/Users/admin/.config/nvim/lua-language-server/3rd/luamake/luamake
(wal -r &)

### OMZ
zinit for \
      OMZL::correction.zsh \
      OMZL::directories.zsh \
      OMZL::history.zsh \
      OMZL::key-bindings.zsh \
      OMZL::theme-and-appearance.zsh \
      OMZP::common-aliases

zinit wait lucid for \
      OMZP::colored-man-pages \
      OMZP::cp \
      OMZP::extract \
      OMZP::fancy-ctrl-z \
      OMZP::sudo

zinit light-mode for \
      zsh-users/zsh-autosuggestions

zinit wait lucid light-mode for \
      zsh-users/zsh-history-substring-search \
      hlissner/zsh-autopair \
      agkozak/zsh-z

### Completion enhancements
zinit ice wait lucid atload"zicompinit; zicdreplay" blockf
zinit light zsh-users/zsh-completions
zinit ice wait lucid from'gh-r' as'program'
zinit light sei40kr/fast-alias-tips-bin
zinit ice wait lucid depth"1"
zinit light sei40kr/zsh-fast-alias-tips

### FZF
zinit light junegunn/fzf
zinit ice wait lucid atload"zicompinit; zicdreplay" blockf
zinit light Aloxaf/fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:(cd|ls|exa|bat|cat|emacs|nano|vi|vim):*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
       '[[ $group == "[process ID]" ]] &&
        if [[ $OSTYPE == darwin* ]]; then
           ps -p $word -o comm="" -w -w
        elif [[ $OSTYPE == linux* ]]; then
           ps --pid=$word -o cmd --no-headers -w -w
        fi'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'

### Utilities
zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zinit light tj/git-extras
zinit light laggardkernel/zsh-thefuck
zinit light jimeh/zsh-peco-history

### Theme 
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

### Alias
source "$HOME/.config/suckless/zsh/alias/app.zsh"
source "$HOME/.config/suckless/zsh/alias/docker.zsh"
source "$HOME/.config/suckless/zsh/alias/general.zsh"
source "$HOME/.config/suckless/zsh/alias/git.zsh"
source "$HOME/.config/suckless/zsh/alias/k8s.zsh"
source "$HOME/.config/suckless/zsh/alias/languages.zsh"
source "$HOME/.config/suckless/zsh/alias/linux.zsh"
source "$HOME/.config/suckless/zsh/alias/network.zsh"
source "$HOME/.config/suckless/zsh/alias/os.zsh"
source "$HOME/.config/suckless/zsh/alias/redis.zsh"
source "$HOME/.config/suckless/zsh/alias/spotify.zsh"
source "$HOME/.config/suckless/zsh/alias/tmux.zsh"
source "$HOME/.config/suckless/zsh/alias/tools.zsh"

### Functions
source "$HOME/.config/suckless/zsh/functions/aws.zsh"
source "$HOME/.config/suckless/zsh/functions/general.zsh"
source "$HOME/.config/suckless/zsh/functions/git.zsh"
source "$HOME/.config/suckless/zsh/functions/k8s.zsh"
source "$HOME/.config/suckless/zsh/functions/tmux.zsh"
source "$HOME/.config/suckless/zsh/functions/vpn.zsh"

### ENV
source "$HOME/.config/suckless/zsh/env/nnn.zsh"
