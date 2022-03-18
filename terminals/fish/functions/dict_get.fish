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
