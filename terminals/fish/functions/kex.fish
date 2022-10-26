function kex --description "K8s Exec pod with /bin/bash"
  set -l pod_name $argv[1];

  # Grep API
  set -l perx_api (kg pods | grep perx-api | awk '{print $1}' | head -1)

  set -l alias_pod \
         perx $perx_api \

  # Get the target pod based on user input
  set -l target_pod (dict_get $pod_name $alias_pod)

  if [ -z $target_pod ]
    kubectl exec -it $pod_name  /bin/bash
  else 
    kubectl exec -it $target_pod /bin/bash
  end
end
