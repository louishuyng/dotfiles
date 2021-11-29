# Text Editor
alias cat='bat'
alias nv="nvim"
alias em="emacs -Q -nw -l ~/.config/emacs/init.el"

# History
alias h='history'

# Listing
alias ll="ls -l"
alias l.='ls -d .* --color=auto'
alias lla="ll -A"

# Jumping
alias z="j"

# Clear & Remove
alias c="clear"
alias rf='rm -rf'
alias cdes="rm ~/Desktop/*"
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
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Restart zsh
alias reset='exec zsh'