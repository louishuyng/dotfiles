#!/usr/bin/env bats

setup() {
  TERN_BIN="${TERN_BIN:-$(command -v tern || true)}"
  [[ -n "$TERN_BIN" ]] || TERN_BIN=/Applications/Tern.app/Contents/MacOS/tern
  [[ -x "$TERN_BIN" ]] || skip "Tern is not installed"
  export TERN_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  export TERN_DAEMON_SOCKET="$BATS_TEST_TMPDIR/unused.sock"
  export STENCIL_FIXTURE_ROOT="$BATS_TEST_TMPDIR/crates/tern"
  mkdir -p "$STENCIL_FIXTURE_ROOT/goldens" "$BATS_TEST_TMPDIR/crates/plugins/fixtures"
  cp -R "$BATS_TEST_DIRNAME/../../terminals/tern" "$BATS_TEST_TMPDIR/crates/plugins/fixtures/tool-keys"
  socket_dir=$(mktemp -d /tmp/tern-mru.XXXXXX)
  CONTROL="$socket_dir/control.sock"
  "$TERN_BIN" serve --control "$CONTROL" --out "$BATS_TEST_TMPDIR/shots" > "$BATS_TEST_TMPDIR/serve.log" 2>&1 &
  server_pid=$!
  for ((i = 0; i < 100; i++)); do
    if ctl state >/dev/null 2>&1; then
      ctl plugins fixtures >/dev/null
      return
    fi
    sleep 0.05
  done
  cat "$BATS_TEST_TMPDIR/serve.log"
  return 1
}

teardown() {
  if [[ -n "${server_pid:-}" ]]; then
    ctl quit >/dev/null 2>&1 || kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  [[ -z "${socket_dir:-}" ]] || rm -rf "$socket_dir"
}

ctl() { "$TERN_BIN" ctl --control "$CONTROL" "$@"; }
current() { ctl state | jq -er '.sessions[] | select(.current) | .name'; }
prefix() {
  ctl key ctrl+a >/dev/null
  ctl key "$1" >/dev/null
}

@test "Tab toggles the two last workspaces without cycling through a third" {
  ctl session rename one >/dev/null
  ctl session new two >/dev/null
  ctl session new three >/dev/null
  prefix shift+1
  prefix shift+2
  [ "$(current)" = two ]
  for expected in one two one two; do
    prefix tab
    [ "$(current)" = "$expected" ]
  done
  prefix shift+3
  prefix tab
  [ "$(current)" = two ]
  prefix tab
  [ "$(current)" = three ]
}

@test "pane and tab changes do not create workspace history" {
  ctl session rename one >/dev/null
  prefix tab
  [ "$(current)" = one ]
  ctl tab new >/dev/null
  ctl split right >/dev/null
  ctl focus left >/dev/null
  prefix tab
  [ "$(current)" = one ]
}
