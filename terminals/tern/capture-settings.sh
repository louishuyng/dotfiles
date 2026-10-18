#!/bin/bash
set -euo pipefail

DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_dir=${TERN_CONFIG_DIR:-"$HOME/Library/Application Support/Tern"}
temporary=$(mktemp "$DIR/.settings.json.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT

cp "$source_dir/settings.json" "$temporary"
jq -e -s 'length == 1 and (.[0] | type == "object")' "$temporary" >/dev/null
mv "$temporary" "$DIR/settings.json"
printf 'Captured Tern settings: %s/settings.json\n' "$DIR"
