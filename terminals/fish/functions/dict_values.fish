function dict_values -d "Print values from a key/value paired list"
  for idx in (seq 2 2 (count $argv))
    echo $argv[$idx]
  end
end
