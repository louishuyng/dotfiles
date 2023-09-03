#! /bin/sh
set -e
# Seeds default roles and keys in vault on first start
# Keeps vault unsealed (available for use by API)

# No env need to create vault seed file and restart container
ensureSealed() {
    VAULT_SEALED=$(vault status -format=json | jq -r '.sealed')
    if [ "false" == "$VAULT_SEALED" ]; then
        vault login $VAULT_ROOT_KEY
        vault operator seal
      fi
}

unpackSeedFile() {
    ensureSealed;
    echo "Will initialize vault using seed zip"
    rm -rf /vault/file/*
    rm -rf /data/vault-seed/
    unzip /data/vault-seed.zip -d /data/vault-seed
    cp /data/vault-seed-file-version /data/vault-seed/vault-seed-file-version
    cp -r /data/vault-seed/* /vault/file
    rm -rf /data/vault-seed
    cp /data/vault-seed-file-version /vault/file/vault-seed-file-version
}


# read env file
export ENV_FILE="/data/env.json"
export VAULT_VERSION_FILE="/data/vault-seed-file-version"

if [ ! -e "$ENV_FILE" ]; then 
  echo "env.json not found will recreate seed file"
  . /data/vault-setup.sh
  unpackSeedFile;
  exit 0
fi 

export VAULT_ADDR=http://vault.localdomain:8200

export VAULT_UNSEAL_KEY=$(cat $ENV_FILE | jq -r '.unsealKey')
export VAULT_ROOT_KEY=$(cat $ENV_FILE | jq -r '.rootKey')

if [ -z "$VAULT_UNSEAL_KEY" ] || [ ! -e "$VAULT_VERSION_FILE" ]; then
    echo "seed file version or unseal key missing will recreate seed file"
    . /data/vault-setup.sh
    unpackSeedFile;
    exit 0
fi

checkSeedVersion() {
  FILE_VERSION=$(cat $VAULT_VERSION_FILE)
  CURRENT_VERSION=$(cat /vault/file/vault-seed-file-version)
  if [ $FILE_VERSION -ne $CURRENT_VERSION ];then 
    echo 'Version mismatch will re init vault seed data'
    ensureSealed;
    rm -rf /vault/file/*
    unpackSeedFile;
    exit 0
  fi  
}

VAULT_INITIALIZED=$(vault status -format=json | jq -r '.initialized')
if [ "false" == $VAULT_INITIALIZED ]; then
   unpackSeedFile;
else
    echo "Vault is already initialized"
    checkSeedVersion;
    echo "Will unseal vault every 5s"
    while true; do
      VAULT_SEALED=$(vault status -format=json | jq -r '.sealed')
      if [ "true" == "$VAULT_SEALED" ]; then
        echo "unsealing vault"
        vault operator unseal $VAULT_UNSEAL_KEY
        echo "vault is unsealed"
      fi
      sleep 5
    done
fi
