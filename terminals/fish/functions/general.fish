function b64 -d "base 64 a file through cat" 
  cat $argv[1] | base64 | pbcopy;
end

function mkd -d "Create a new directory and enter it" 
  mkdir -p $argv && cd $argv;
end

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


function goto -d 'cd to lib real path'
  set -l path (realpath $(which $argv[1]) | awk 'sub( /\/[a-z]*$/,"",$0 )')

  cd $path
end
#
function sys_log -d 'tail system log' 
  tail -f ~/sys_log/$argv[1].log
end
