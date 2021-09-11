function minikd() {
  DRIVER=$1

  if [[ -z $DRIVER ]]
  then
    echo "Please set Driver"
    return
  fi
  minikube start --driver=$DRIVER
}
