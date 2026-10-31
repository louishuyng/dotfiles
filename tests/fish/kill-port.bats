#!/usr/bin/env bats

setup() {
  FUNCTION="$BATS_TEST_DIRNAME/../../terminals/fish/functions/kill-port.fish"
  export PATH="$BATS_TEST_TMPDIR:$PATH"
  export CALLS="$BATS_TEST_TMPDIR/kill-args"
  export LOOKUP="$BATS_TEST_TMPDIR/lsof-args"
  cat > "$BATS_TEST_TMPDIR/lsof" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$LOOKUP"
if [ -z "${PIDS:-}" ]; then exit 1; fi
printf '%s\n' "$PIDS"
EOF
  cat > "$BATS_TEST_TMPDIR/kill" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$CALLS"
exit "${KILL_STATUS:-0}"
EOF
  chmod +x "$BATS_TEST_TMPDIR/lsof" "$BATS_TEST_TMPDIR/kill"
}

@test "invalid arguments never look up or signal processes" {
  for port in '' abc 0 65536 -1 80,443 999999999999999999999; do
    run fish --no-config -c 'source $argv[1]; kill-port $argv[2]' "$FUNCTION" "$port"
    [ "$status" -eq 2 ]
    [[ "$output" == *'Usage: kill-port'* ]]
  done
  run fish --no-config -c 'source $argv[1]; kill-port 80 443' "$FUNCTION"
  [ "$status" -eq 2 ]
  [ ! -e "$LOOKUP" ]
  [ ! -e "$CALLS" ]
}

@test "an unused port does not signal anything" {
  run fish --no-config -c 'source $argv[1]; kill-port 3000' "$FUNCTION"
  [ "$status" -eq 0 ]
  [[ "$output" == *'No TCP listener found on port 3000'* ]]
  [ ! -e "$CALLS" ]
}

@test "only TCP listeners on the requested port receive SIGTERM" {
  export PIDS=$'1234\n5678'
  run fish --no-config -c 'source $argv[1]; kill-port 65535' "$FUNCTION"
  [ "$status" -eq 0 ]
  [ "$(cat "$LOOKUP")" = "$(printf '%s\n' -nP -t -iTCP:65535 -sTCP:LISTEN)" ]
  [ "$(cat "$CALLS")" = "$(printf '%s\n' -TERM 1234 5678)" ]
}

@test "a failed signal returns failure without reporting success" {
  export PIDS=1234 KILL_STATUS=1
  run fish --no-config -c 'source $argv[1]; kill-port 3000' "$FUNCTION"
  [ "$status" -eq 1 ]
  [[ "$output" != *'Sent SIGTERM'* ]]
}
