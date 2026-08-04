#!/usr/bin/env bats
# Verifies the guard predicate directly. Running the real block would exec
# herdr and take over the test runner, so the condition is evaluated alone.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  COND='status is-interactive; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY'
}

@test "config.fish keeps the guarded autostart present but intentionally disabled" {
  # The user launches herdr manually, by choice, so the block must be
  # commented out rather than absent (it stays as documentation of the guard)
  # and rather than active. Whole-line match on the commented form, not
  # fragments: dropping the TMUX or SSH_TTY clause, losing
  # `status is-interactive`, or reordering must all fail here. COND is the
  # same string tests 2-5 evaluate, so the two cannot drift apart.
  grep -qxF "# if $COND" "$REPO/terminals/fish/config.fish"
  grep -qxF '#     exec herdr' "$REPO/terminals/fish/config.fish"
  grep -qxF '# end' "$REPO/terminals/fish/config.fish"

  # An active, uncommented copy would mean autostart got re-enabled.
  ! grep -qxF "if $COND" "$REPO/terminals/fish/config.fish"
  ! grep -qxF '    exec herdr' "$REPO/terminals/fish/config.fish"

  # A comment must record that this is deliberate, so nobody "fixes" it by
  # uncommenting.
  grep -qi 'manually' "$REPO/terminals/fish/config.fish"
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
