### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
	print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
	command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
	command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
		print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
		print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
source "$HOME/.config/suckless/zsh/.zshenv"
source "$HOME/.config/suckless/zsh/config.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# if [ -z "$TMUX" ]
# then
#     tmux attach -t work || tmux new -s work
# fi

# Theme
zinit ice depth=1 atload"!source ~/.config/suckless/zsh/.p10k-evilball.zsh" lucid nocd

zinit light romkatv/powerlevel10k

# Oh-my-zsh lib
zinit snippet OMZ::lib/history.zsh

zinit snippet OMZ::lib/key-bindings.zsh

zinit ice wait lucid
zinit snippet OMZ::lib/grep.zsh

zinit ice wait lucid
zinit snippet OMZ::lib/completion.zsh

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

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

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
