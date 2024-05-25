function s -d 'search using rg'
  set -l expression $argv[1];
  set -l path $argv[2];

  clear

  if [ -z $path ]
    rg $expression
  else
    # If path don't have any child directory then search in the current directory
    if test -z (ls -d "$path*/")
      rg $expression --glob "$path*"
    end

    # If path have child directory then search in the child directory
    if test -n (ls -d "$path*/")
      rg $expression --glob "$path*/**"
    end

    # If path is a file then search in the file
    if test -f "$path"
      rg $expression --glob "$path"
    end
  end
end
