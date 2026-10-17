#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../../scripts/nvim-tab.sh"
  export TERM_PROGRAM=tern TERN_PANE=10
  export PATH="$BATS_TEST_TMPDIR:$PATH"
  export CALLS="$BATS_TEST_TMPDIR/calls"
  export STATE='{"sessions":[{"tabs":[
    {"blocks":[{"id":20,"live":true,"exited":null}]},
    {"blocks":[{"id":10,"live":true,"exited":null},{"id":11,"live":true,"exited":null},{"id":12,"live":false,"exited":0}]}
  ]}]}'
  cat > "$BATS_TEST_TMPDIR/tern" <<'EOF'
#!/bin/bash
case "$1" in
  ls) printf '%s\n' "$STATE" ;;
  process)
    if [ "$2" = "${FAIL_PANE:-}" ]; then exit 2; fi
    if [ "$2" = "${NVIM_PANE:-20}" ]; then
      printf '{"child":{"name":"fish","argv":["fish"]},"foreground":{"name":"nvim","argv":["/opt/homebrew/bin/nvim"]}}\n'
    else
      printf '{"child":{"name":"fish","argv":["fish"]},"foreground":{"name":"fish","argv":["fish"]}}\n'
    fi ;;
  split)
    printf '%s\n' "$*" >> "$CALLS"
    printf '30\n' ;;
  *) printf '%s\n' "$*" >> "$CALLS" ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/tern"
}

@test "Neovim in another tab does not prevent a right split in the current directory" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "$(printf 'split 10 right --cwd %s -- exec nvim\nfocus 30' "$PWD")" ]
}

@test "Neovim in the current tab is focused instead of duplicated" {
  export NVIM_PANE=11
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "focus 11" ]
}

@test "an exited Neovim block is not reused" {
  export NVIM_PANE=12
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "$(printf 'split 10 right --cwd %s -- exec nvim\nfocus 30' "$PWD")" ]
}

@test "a failed process lookup never creates a duplicate" {
  export FAIL_PANE=11
  run bash "$SCRIPT"
  [ "$status" -eq 2 ]
  [ ! -e "$CALLS" ]
}

@test "an unknown current pane never targets the shown tab" {
  export TERN_PANE=99
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [ ! -e "$CALLS" ]
}

@test "a Neovim launch still starting is reused without another split" {
  export STATE='{"sessions":[{"tabs":[{"blocks":[
    {"id":10,"live":true,"exited":null},
    {"id":11,"live":true,"exited":null,"command":"exec nvim"}
  ]}]}]}'
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "focus 11" ]
}
