function b64 -d "base 64 a file through cat" 
  cat $argv[1] | base64 | pbcopy;
end
