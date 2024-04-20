helm repo add traefik https://traefik.github.io/charts
helm dep update .
kubectl create namespace development

helm install \
     --atomic \
     --wait \
     --create-namespace \
     --namespace traefik \
     -f values.yaml \
     traefik ./
