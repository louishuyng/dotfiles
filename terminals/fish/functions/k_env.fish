function k_env -d "get kubernetes environment of one service"
  set -l service $argv[1]
  set -l namespace $argv[2]

  k exec $(kubectl get pods -o=name --namespace $namespace | grep "pod/$service*" | awk -F / '{print $2}') --namespace $namespace -- env | pbcopy
end
