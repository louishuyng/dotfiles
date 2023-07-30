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
alias dka="docker kill (docker ps -q)"

#K8S
alias km='minikd'

# Essential aliases. I strongly recommend setting them
alias k='kubectl'
alias kg='k get'
alias kgpo='k get pods'
alias kgno='k get nodes'
alias kdpo='k describe pod'
alias kd='k describe'
alias kde='k delete'
alias kl='k logs'
alias ked='kubectl edit'
alias kcr='kubectl create'

# I also found this one very useful
alias kap='k apply -f'

# I have this for work only
alias kgpoa='kgpo --all-namespaces'
alias kgpol='kgpo --show-labels'
alias kgpow='kgpo -o wide'
alias kgd='kg deploy'
alias kgs='kg svc'
alias kdd='kd deploy'
alias kds='kd svc'

#Terraform
alias tf='terraform'

#Ansible
alias as='ansible'
alias aspb='ansible-playbook'

#Kubectx
alias k8sns='kubens'

#Postgres
alias pgr="pg_ctl -D /usr/local/var/postgres restart"

#Mongo
alias mgr="brew services start mongodb-community@5.0"
alias mgs="brew services stop mongodb-community@5.0"

#Devops Remap Tools
alias cat='bat'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias size="du -sh"

alias ls="exa --long  --header --git"
alias lt="exa --tree --level=2 --long --icons --header --git"

alias http='xh'

alias du='ncdu'
alias df='duf'

alias top2='bpytop'

alias find='fd'
alias lf='ranger'
