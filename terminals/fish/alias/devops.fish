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
alias dkr="open -a 'Docker'"
alias dks="killall Docker"
alias dkc="docker system prune"

#K8S
alias k8smd='minikd'
alias k8s='kubectl'

# Basic Commands
alias k8sa='kubectl apply'
alias k8sc='kubectl create'
alias k8sdel='kubectl delete'
alias k8sdes='kubectl describe'
alias k8sed='kubectl edit'
alias k8sex='kubectl exec'
alias k8sg='kubectl get'
alias k8sl='kubectl logs'

#Kubectx
alias k8sns='kubens'

#Postgres
alias pgr="pg_ctl -D /usr/local/var/postgres restart"

#Mongo
alias mgr="brew services start mongodb-community@5.0"
alias mgs="brew services stop mongodb-community@5.0"
