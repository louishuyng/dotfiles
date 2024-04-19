kubectl config set-context --current --namespace=traefik

printf "Traefik dashboard is available at http://127.0.0.1:9000/dashboard/\n"

kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000

