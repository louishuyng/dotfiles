#!/usr/bin/env bats
# herdr disables invalid keybindings with only a warning, so "no warnings" is
# the real gate — `config: ok` alone would pass with every binding dead.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  XDG="$BATS_TEST_TMPDIR/xdg"
  mkdir -p "$XDG/herdr"
  cp "$REPO/terminals/herdr/config.toml" "$XDG/herdr/config.toml"
}

@test "config validates with no disabled bindings" {
  run env XDG_CONFIG_HOME="$XDG" herdr config check
  [ "$status" -eq 0 ]
  [[ "$output" == *"config: ok"* ]]
  [[ "$output" != *"invalid keybinding"* ]]
}

@test "prefix is ctrl+a" {
  grep -q '^prefix = "ctrl+a"$' "$XDG/herdr/config.toml"
}

@test "theme follows host appearance" {
  grep -q '^auto_switch = true$' "$XDG/herdr/config.toml"
}

@test "cycle_pane_next is cleared so last_pane can own prefix+tab" {
  grep -q '^cycle_pane_next = ""$' "$XDG/herdr/config.toml"
  grep -q '^last_pane = "prefix+tab"$' "$XDG/herdr/config.toml"
}
