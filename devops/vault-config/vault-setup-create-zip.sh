#! /bin/sh
set -e

INCREMENT=$1

if [ -f "/data/vault-seed-file-version" ]; then
  export SEED_VERSION=$(cat /data/vault-seed-file-version)
else
  export SEED_VERSION=0
fi 

rm -rf /data/vault-seed.zip
cd /vault/file
zip -r "/data/vault-seed.zip" .
rm -rf /vault/file/*

if [ -n "$INCREMENT" ]; then 
  echo $(($SEED_VERSION + 1)) > /data/vault-seed-file-version
else 
  echo 1 > /data/vault-seed-file-version
fi
