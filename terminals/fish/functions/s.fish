function s -d 'search using rg'
  set -l expression $argv[1];
  set -l path $argv[2];

  clear

  if [ -z $path ]
    rg $expression
  else
    rg $expression --glob $path
  end
end
