# Text Editor
alias cat='bat'
# TODO: remove when nvim update version to 0.8
alias nv="~/development/nvim-dev/bin/nvim" #Nvim dev prerelease
alias nvt='nvim --cmd "set rtp+=./"'
alias em="emacs -Q -nw -l ~/.config/emacs/init.el"
alias c="clear"

# History
alias h='history'

# Listing
alias ls="exa --long  --header --git"
alias ll="ls -l"
alias l.='ls -d .* --color=auto'
alias lla="ll -A"

# Clear & Remove
alias rf='rm -rf'
alias cdes="rm ~/Desktop/*; rm -rf ~/Desktop/*"
alias cfdes="rm -rf ~/Desktop/*"

# Navigating
alias ..="cd .."
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

# Colorize the grep command
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# New set command
alias path='echo -e $PATH\n'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Restart zsh
alias reset='exec fish'

# Utils
alias size="du -sh"

# Zoxide
alias zz="z -"
