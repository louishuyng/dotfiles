#!/usr/bin/env bats

setup() {
  checkout="$BATS_TEST_TMPDIR/checkout with spaces"
  mkdir -p "$checkout" "$BATS_TEST_TMPDIR/live config"
  cp "$BATS_TEST_DIRNAME/../../terminals/tern/capture-settings.sh" "$checkout/"
  SCRIPT="$checkout/capture-settings.sh"
  export TERN_CONFIG_DIR="$BATS_TEST_TMPDIR/live config"
  printf '{"theme":"original"}\n' > "$checkout/settings.json"
}

@test "captures all native preferences without changing the live file" {
  printf '{"theme":"System","keybinds":{"ctrl+\\\\":"plugin.tool-keys.toggle_files"}}\n' > "$TERN_CONFIG_DIR/settings.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  cmp "$TERN_CONFIG_DIR/settings.json" "$checkout/settings.json"
  [ ! -L "$checkout/settings.json" ]
}

@test "invalid, non-object, or multiple JSON values do not replace the snapshot" {
  for invalid in '{"theme":' '[]' '{} {}'; do
    printf '%s\n' "$invalid" > "$TERN_CONFIG_DIR/settings.json"
    run bash "$SCRIPT"
    [ "$status" -ne 0 ]
    [ "$(cat "$checkout/settings.json")" = '{"theme":"original"}' ]
  done
}

@test "missing native settings do not replace the snapshot" {
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [ "$(cat "$checkout/settings.json")" = '{"theme":"original"}' ]
}
