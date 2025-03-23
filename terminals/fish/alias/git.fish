alias glp='git log --pretty=format:"%C(yellow)%h%Creset - %C(green)%an%Creset, %ar : %s"'

alias gb='git branch'
alias gco='git checkout'

alias gcm='git commit -m'
alias gcp='git cherry-pick'

alias gs='git status'
alias gst='git stash'

alias gp='git push'
alias gpf='git push --force-with-lease'

alias gm='git merge'
alias gl='git pull'
alias glo='git pull origin'

alias grs='git reset --soft'
alias grh='git reset --hard'

alias ghcs='gh copilot suggest'
alias ghce='gh copilot explain'

alias yo='git add -A && git commit -m "$(curl -s https://whatthecommit.com/index.txt)" --no-verify && git push origin HEAD'
