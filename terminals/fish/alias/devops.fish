#Redis
alias rds='brew services start redis'
alias rdc='brew services stop redis'

#Docker
alias dcd="docker-compose down"
alias dcu="docker-compose up"
alias dcud="docker-compose up -d"
alias dce="docker-compose exec"
alias dps="docker ps -a"
alias dpsa="docker ps -a"
alias dr="open -a 'Docker'"
alias ds="killall Docker"
alias dc="docker system prune"
alias dca="docker kill (docker ps -q)"

#K8S
alias km='minikd'

# Essential aliases. I strongly recommend setting them
alias k='kubectl'
alias kns='kubens'
alias kctx='kubectx'

export do="--dry-run=client -o yaml"
export label="--show--labels"

#Terraform
alias tf='terraform'

# Vault
alias va="vault"

#Postgres
alias pgr="pg_ctl -D /usr/local/var/postgres restart"

#Mongo
alias mgr="brew services start mongodb-community@5.0"
alias mgs="brew services stop mongodb-community@5.0"

#Devops Remap Tools
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias size="du -sh"

alias ls="exa --long  --header --git"
alias lt="exa --tree --level=2 --long --icons --header --git"

alias http='xh'

alias du='ncdu'

alias top2='bpytop'

alias find='fd'
alias lf='ranger'

alias api='hurl --variables-file vars.env'
