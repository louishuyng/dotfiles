#! /bin/sh
# run commands in this script one by one to generate seed data 
# ********** DO NOT EDIT ***********
set -e

export VAULT_ADDR=http://vault.localdomain:8200

# give some time for Vault to start and be ready
sleep 3
INIT_RESPONSE=$(vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json)

echo "**Vault is initialized**"
echo $INIT_RESPONSE

UNSEAL_KEY_BASE=$(echo "$INIT_RESPONSE" | jq -r '.unseal_keys_b64[0]')
ROOT_KEY=$(echo "$INIT_RESPONSE" | jq -r '.root_token')

echo "Unseal key:"
echo $UNSEAL_KEY_BASE
echo "Root key:"
echo $ROOT_KEY

vault operator unseal $UNSEAL_KEY_BASE
vault login $ROOT_KEY
# ********** DO NOT EDIT ***********




# ********** Edit from here ***********

# enable vault transit engine
vault secrets enable transit

# create key1 with type ed25519
vault write -f transit/keys/key128 type=aes128-gcm96
vault write -f transit/keys/key256 type=aes256-gcm96


vault policy write encrypt-data -<<EOF
path "transit/encrypt/key128" {
   capabilities = [ "update" ]
}
path "transit/decrypt/key128" {
   capabilities = [ "update" ]
}
path "transit/encrypt/key256" {
   capabilities = [ "update" ]
}
path "transit/decrypt/key256" {
   capabilities = [ "update" ]
}
EOF

vault auth enable approle
vault write auth/approle/role/myRole1 \
  token_ttl=30s \
  token_max_ttl=30s \
  policies=encrypt-data

myRole1ID=$(vault read auth/approle/role/myRole1/role-id -format=json | jq -r '.data.role_id')

myRole1Secret=$(vault write -f auth/approle/role/myRole1/secret-id -format=json | jq -r '.data.secret_id')

# Add more keys if needed
env="{
  \"unsealKey\": \"$UNSEAL_KEY_BASE\",
  \"rootKey\": \"$ROOT_KEY\",

  \"myRole1ID\": \"$myRole1ID\",
  \"myRole1Secret\": \"$myRole1Secret\"
}"
echo $env
echo $env > /data/env.json

# ********** DO NOT EDIT ***********
vault operator seal
# create file increment of vault
. /data/vault-setup-create-zip.sh
# ********** DO NOT EDIT ***********
