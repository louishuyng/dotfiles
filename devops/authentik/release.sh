helm upgrade --install \
             --atomic \
             --wait \
             --create-namespace \
             --namespace authentication \
             -f values.yaml \
             authentik ./
