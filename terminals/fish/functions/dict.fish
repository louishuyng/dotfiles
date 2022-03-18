function dict_keys -d "Print keys from a key/value paired list"
  for idx in (seq 1 2 (count $argv))
    echo $argv[$idx]
  end
end

function dict_values -d "Print values from a key/value paired list"
  for idx in (seq 2 2 (count $argv))
    echo $argv[$idx]
  end
end

function dict_get -a key -d "Get the value associated with a key in a k/v paired list"
  test (count $argv) -gt 2 || return 1
  set -l keyseq (seq 2 2 (count $argv))
  # we can't simply use `contains` because it won't distinguish keys from values
  for idx in $keyseq
      if test $key = $argv[$idx]
          echo $argv[(math $idx + 1)]
          return
      end
  end
  return 1
end
