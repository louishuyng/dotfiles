#!/usr/bin/env bash
set -e

script_dir=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/../../../.." && pwd)
exec /bin/bash "$repo_root/bootstrap/mac.sh" --tasks desktop "$@"
