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

#K8S
alias km='minikd'
alias k='kubectl'

# Basic Commands
alias ka='kubectl apply'
alias kc='kubectl create'
alias kd='kubectl delete'
alias kds='kubectl describe'
alias ked='kubectl edit'
alias kg='kubectl get'
alias kl='kubectl logs'

#Kubectx
alias k8sns='kubens'

#Postgres
alias pgr="pg_ctl -D /usr/local/var/postgres restart"

#Mongo
alias mgr="brew services start mongodb-community@5.0"
alias mgs="brew services stop mongodb-community@5.0"
