function ssh_join -d "Join remote server by host name"
  set -l host_key \
         oivan-test id_rsa_oivan \
         oivan-dev id_rsa_oivan \
         rocky id_rsa_open_source

  set -l host_name $argv[1]

  set ssh_key (dict_get $host_name $host_key); ssh "$host_name" -i "~/.ssh/$ssh_key"
end
