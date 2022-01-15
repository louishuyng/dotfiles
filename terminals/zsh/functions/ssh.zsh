declare -A host_key

host_key[elxr-stg]=bastion.pem
host_key[elxr-prod]=bastion.pem
host_key[oivan-test]=id_rsa_oivan
host_key[oivan-dev]=id_rsa_oivan
host_key[dgo-sg]=id_rsa_open_source

function ssh_join() {
  host_name=$1

  ssh $host_name -i ~/.ssh/$host_key[$host_name]
}

