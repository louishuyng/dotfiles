#! /bin/bash
set -e

script_dir=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec /bin/bash "$script_dir/setup.sh" arch "$@"
