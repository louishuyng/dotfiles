helm upgrade --install \
             --atomic \
             --wait \
             --create-namespace \
             --namespace traefik \
             -f values.yaml \
             traefik ./
