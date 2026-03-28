#K8S
alias km='minikd'

# Essential aliases. I strongly recommend setting them
alias k='kubectl'
alias kg='k get'
alias kc='k create'
alias ke='k edit'
alias ka='k apply'
alias kd='k describe'
alias kl='k logs'
alias kde='k delete'
alias ksc='k scale'

export do="--dry-run=client -o yaml"
export label="--show--labels"

#K9s
alias regask-staging='k9s --namespace=staging --context k8s-qa-cluster'
alias regask-uat='k9s --namespace=pre-prod --context k8s-qa-cluster'
alias regask-prod='k9s --namespace=production --context k8s-production-cluster'
alias regask-dev='k9s --namespace=development --context k8s-qa-cluster'
alias orb-local='k9s --namespace=all --context k8s-orb-cluster'
