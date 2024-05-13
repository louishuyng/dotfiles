function p-clean -d 'clean all major processes'
  set -l array node ruby k9s

  for element in $array
    if killall $element > /dev/null 2>&1
      echo "Successfully killed $element"
    else
      echo "No running $element processes"
    end
  end
end
