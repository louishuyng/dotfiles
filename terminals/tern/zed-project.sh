#! /bin/bash
set -e

target=${1:?Expected a file or repository path}
directory=$target
if [ ! -d "$directory" ]; then
  directory=$(dirname -- "$target")
fi
root=$(git -C "$directory" rev-parse --show-toplevel)

if [ -d "$target" ]; then
  exec zed --wait "$root"
fi
exec zed --wait "$root" "$target"
