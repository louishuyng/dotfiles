#!/opt/homebrew/bin/bash

helm repo add kong https://charts.konghq.com
helm repo update

# Create a namespace for Kong
kubectl create namespace kong

# Create a secret for Kong Free Enterprise License
kubectl create secret generic kong-enterprise-license --from-literal=license="'{}'" -n kong

# Generate a certificate for Kong Clustering
openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout ./tls.key -out ./tls.crt -days 1095 -subj "/CN=kong_clustering"
kubectl create secret tls kong-cluster-cert --cert=./tls.crt --key=./tls.key -n kong

# Install Kong Values for Control Plane and Data Plane
helm install kong-cp kong/kong -n kong --values ./values-cp.yaml
helm install kong-dp kong/kong -n kong --values ./values-dp.yaml
