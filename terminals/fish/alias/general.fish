# Bash
alias unset 'set --erase'

alias fetch='neofetch'

# Text Editor
alias nv="nvim"
alias nvt='nvim --cmd "set rtp+=./"'
alias em="emacs -nw"
alias c="clear"

# History
alias h='history'

# Listing
alias ls="eza --long  --header --git"
alias lt="eza --tree --level=2 --long --icons --header --git"
alias ll="ls -l"

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

# Zoxide
alias zz="z -"

# Firefox
alias firefox="/Applications/Firefox.app/Contents/MacOS/firefox"
