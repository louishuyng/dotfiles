#!/usr/bin/env bash
# stdin -> stdout formatter for Gram's `external` formatter.
#
# Mirrors the conform chains in nvim/lua/config/lsp/register_formatters.lua:
#   ts/tsx/js/jsx  oxfmt (project-local only) -> fmtkit -> prettier
#   go             fmtkit -> gofmt
# first one that applies wins. Gram's external formatter takes a fixed command,
# so the per-project resolution conform does with `condition` callbacks has to
# happen here instead.
#
# Buffer content arrives on stdin; $1 is the buffer path, used only to decide
# which formatter applies. If nothing applies, or a formatter fails, the input
# is echoed back byte-for-byte — Gram replaces the buffer with whatever lands
# on stdout, so emitting nothing would empty the file.
#
# `format.sh --self-check` verifies the pass-through path.

set -uo pipefail

PATH="/opt/homebrew/bin:$PATH"

if [ "${1:-}" = --self-check ]; then
  d=$(mktemp -d)
  trap 'rm -rf "$d"' EXIT
  printf 'const  x=1\n\n' >"$d/in.ts"
  # No node_modules, no Makefile, no prettier on PATH: must pass through intact.
  PATH=/usr/bin:/bin bash "$0" "$d/nope.ts" <"$d/in.ts" | cmp -s - "$d/in.ts" ||
    { echo "FAIL: no-formatter case did not pass input through" >&2; exit 1; }
  # An unhandled extension must pass through too, not blank the buffer.
  bash "$0" "$d/nope.txt" <"$d/in.ts" | cmp -s - "$d/in.ts" ||
    { echo "FAIL: unknown extension did not pass input through" >&2; exit 1; }
  echo "self-check ok"
  exit 0
fi

buffer_path=${1:-}

in=$(mktemp -t gram-format-in) || exit 1
out=$(mktemp -t gram-format-out) || exit 1
work=
trap 'rm -f "$in" "$out" ${work:+"$work"}' EXIT
cat >"$in"

emit_original() { cat "$in"; exit 0; }

[ -n "$buffer_path" ] || emit_original

# Walk up from $1 looking for the relative path $2.
find_upwards() {
  local dir=$1 rel=$2
  while :; do
    [ -e "$dir/$rel" ] && { printf '%s' "$dir/$rel"; return 0; }
    [ "$dir" = / ] && return 1
    dir=$(dirname "$dir")
  done
}

# fmtkit has no config file, so the only marker is a Makefile that drives it.
is_fmtkit_project() {
  local dir=$1
  command -v fmtkit >/dev/null || return 1
  while :; do
    [ -f "$dir/Makefile" ] && grep -qF fmtkit "$dir/Makefile" && return 0
    [ "$dir" = / ] && return 1
    dir=$(dirname "$dir")
  done
}

# Feed the buffer through a stdin/stdout formatter; keep the result only if it
# succeeded non-empty.
run() {
  if "$@" <"$in" >"$out" 2>/dev/null && [ -s "$out" ]; then
    cat "$out"
  else
    cat "$in"
  fi
  exit 0
}

# Same, for formatters that only rewrite a file in place (fmtkit). The copy has
# to be a hidden sibling of the real buffer, not a file in /tmp: `fmtkit ts`
# resolves paths against the enclosing git repo and exits 128 outside one.
# Never write to $buffer_path itself — Gram writes the buffer after formatting,
# so touching the file behind its back loses whichever write lands second.
run_inplace() {
  work="$dir/.gram-fmt.$$.${buffer_path##*.}"
  cp "$in" "$work" || emit_original
  "$@" "$work" >/dev/null 2>&1 && [ -s "$work" ] || emit_original
  cat "$work"
  exit 0
}

dir=$(dirname "$buffer_path")

case ${buffer_path##*.} in
go)
  is_fmtkit_project "$dir" && run_inplace fmtkit go format
  command -v gofmt >/dev/null && run gofmt
  ;;
ts | tsx | mts | cts | js | jsx | mjs | cjs)
  if oxfmt=$(find_upwards "$dir" node_modules/.bin/oxfmt); then
    # Match `pnpm format`, which points oxfmt at the shared config in node_modules.
    if cfg=$(find_upwards "$dir" node_modules/@regask/standard-oxfmt-service/.oxfmtrc.json); then
      run "$oxfmt" --stdin-filepath "$buffer_path" --config "$cfg"
    fi
    run "$oxfmt" --stdin-filepath "$buffer_path"
  fi
  is_fmtkit_project "$dir" && run_inplace fmtkit ts
  if prettier=$(find_upwards "$dir" node_modules/.bin/prettier); then
    run "$prettier" --stdin-filepath "$buffer_path"
  elif command -v prettier >/dev/null; then
    run prettier --stdin-filepath "$buffer_path"
  fi
  ;;
esac

emit_original
