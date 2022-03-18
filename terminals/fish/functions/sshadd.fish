function sshadd -d "using ssh by key name" 
  set -l name $argv[1];

  ssh-add -D

  if [ -z $name ]
    ssh-add --apple-use-keychain  ~/.ssh/id_rsa
  else if [ -f $HOME/.ssh/id_rsa_$name ]
    ssh-add --apple-use-keychain ~/.ssh/id_rsa_$name
  else
    ssh-add --apple-use-keychain ~/.ssh/$name
  end
end
