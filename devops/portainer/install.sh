helm dep update .

helm install \
     --atomic \
     --wait \
     --create-namespace \
     --namespace management \
     -f values.yaml \
     portainer ./

