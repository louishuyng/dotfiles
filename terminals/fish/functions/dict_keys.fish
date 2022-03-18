function dict_keys -d "Print keys from a key/value paired list"
  for idx in (seq 1 2 (count $argv))
    echo $argv[$idx]
  end
end
