function ps_of -d 'show ps of process'
  ps -ef | awk "{ if(\$NF == \"$argv[1]\") print \$0}"
end
