helm upgrade --install \
             --atomic \
             --wait \
             --create-namespace \
             --namespace observability \
             -f values.yaml \
             jaeger ./
