function minikd() {
  DRIVER=$1

  if [[ -z $DRIVER ]]
  then
    echo "Please set Driver"
    return
  fi
  minikube start --driver=$DRIVER
}

function k8sgw() {
  COMPONENT=$1
  if [[ -z $COMPONENT ]]
  then
    echo "Please set Component"
    return
  fi
  kubectl get $COMPONENT --watch
}
