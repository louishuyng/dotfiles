alias cat='bat'
alias nv="nvim"
alias c="clear"
alias rf='rm -rf'
alias sdn="osascript -e 'tell app \"System Events\" to shut down'"
alias ll="ls -l"
alias lla="ll -A"
alias z="j"
alias cdes="rm ~/Desktop/*"

# TOOLS
alias speedTest='speed-test'
alias ra='ranger'

# TMUX
alias tm='tmux  -u'

# GIT
alias gm='git merge'
alias gs='git status'
alias gst='git stash'
alias gps='git push'
alias gp='git pull'
alias gpo='git pull origin'
alias gco='git checkout'
alias gci='git commit'
alias grs='git reset --soft'
alias grh='git reset --hard'
alias gd='git diff'

# APP OR WEB SHORTCUT
alias facebook="open -a 'Brave Browser' http://www.facebook.com "
alias youtube="open -a 'Brave Browser' http://www.youtube.com "
alias netflix="open -a 'Brave Browser' http://www.netflix.com "

# LANGUAGES
# JS
alias rnm='rm  -rf node_modules'
alias npmi='npm install'
alias rnmai='rm -rf node_modules && yarn'

# RAILS
alias bdi='bundle install'
alias bdu='bundle update --bundler'
alias railst='bundle exec rspec'
alias railss='bundle exec rails s -p'
alias railsm='bundle exec rails db:migrate'
alias railsg='bundle exec rails generate'

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
alias renewip='sudo ipconfig set en0 BOOTP && sudo ipconfig set en0 DHCP'
