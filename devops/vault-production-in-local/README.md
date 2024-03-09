Create "RAFT" storage backend directory
``` bash
mkdir -p ~/Dev/vault/data
```

Starting vault server using config.hcl 
```bash
vault server -config=/Users/louishuyng/.dotfiles/devops/vault-production-in-local/config.hcl
```

Export VAULT_ADDR
```bash
export VAULT_ADDR='http://127.0.0.1:8200'
```

Initialize vault
```bash
vault operator init
```
