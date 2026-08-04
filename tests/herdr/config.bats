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

@test "all ten launchers are bound" {
  for k in 'prefix+/' 'prefix+i' 'prefix+t' 'prefix+shift+r' 'prefix+a' \
           'prefix+ctrl+r' 'prefix+g' 'prefix+n' 'prefix+p' 'prefix+s'; do
    grep -qF "key = \"$k\"" "$XDG/herdr/config.toml" || {
      echo "missing launcher: $k"; return 1
    }
  done
}

@test "pane swap is bound on all four arrows" {
  for d in left right up down; do
    grep -qF "herdr pane swap --current --direction $d" "$XDG/herdr/config.toml" || {
      echo "missing swap: $d"; return 1
    }
  done
}

@test "theme toggle runs the appearance script, not a config rewrite" {
  grep -qF 'toggle-appearance.sh' "$XDG/herdr/config.toml"
  [ -x "$REPO/terminals/herdr/scripts/toggle-appearance.sh" ]
}
