helm upgrade --install \
             --atomic \
             --wait \
             --create-namespace \
             --namespace management \
             -f values.yaml \
             portainer ./
