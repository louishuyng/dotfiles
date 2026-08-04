#!/usr/bin/env bats
# Verifies the guard predicate directly. Running the real block would exec
# herdr and take over the test runner, so the condition is evaluated alone.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  COND='status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY'
}

@test "config.fish contains the guarded autostart" {
  grep -qF 'not set -q HERDR_ENV' "$REPO/terminals/fish/config.fish"
  grep -qF 'exec herdr' "$REPO/terminals/fish/config.fish"
}

@test "guard blocks inside a herdr pane" {
  run fish -c "set -gx HERDR_ENV 1; if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}

@test "guard blocks inside tmux" {
  run fish -c "set -gx TMUX /tmp/fake; if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}

@test "guard blocks over ssh" {
  run fish -c "set -gx SSH_TTY /dev/ttys999; if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}

@test "guard blocks in a non-interactive shell" {
  run fish -c "if $COND; echo LAUNCH; else; echo SKIP; end"
  [[ "$output" == "SKIP" ]]
}
