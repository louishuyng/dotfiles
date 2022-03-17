# REDIS
alias rds='brew services start redis'
alias rdc='brew services stop redis'

#DOCKER
alias dkcd="docker-compose down"
alias dkcu="docker-compose up"
alias dkcud="docker-compose up -d"
alias dpsa="docker ps -a"
alias dks="open -a 'Docker'"
alias dkc="killall Docker"

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

# Kubectx
alias k8sns='kubens'

#DATABASE
# Postgres
 alias pgr="pg_ctl -D /usr/local/var/postgres restart"
