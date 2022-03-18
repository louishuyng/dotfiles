function goto -d 'cd to lib real path'
  set -l path (realpath $(which $argv[1]) | awk 'sub( /\/[a-z]*$/,"",$0 )')

  cd $path
end
