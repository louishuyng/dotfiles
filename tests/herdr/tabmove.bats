#!/usr/bin/env bats
# tab-move.sh speaks the socket API directly (no `herdr tab move` CLI exists),
# so these tests exercise only the index arithmetic via --dry-run against a
# fake `tab list`. The insert_index formulas themselves were verified against
# a live server in a throwaway workspace; see the task-9 report.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCRIPT="$REPO/terminals/herdr/scripts/tab-move.sh"
}

# fake_herdr <tabs_json>
#   <tabs_json> becomes the value of .result.tabs for `tab list`.
fake_herdr() {
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo '{"result":{"tabs":$1}}'
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr"
}

fake_herdr_fail() {
  cat > "$BATS_TEST_TMPDIR/herdr" <<'EOF'
#!/opt/homebrew/bin/bash
exit 1
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr"
}

# Three tabs [A,B,C] in workspace w1, each fixture interleaved with an
# unrelated w9 tab so filtering by workspace_id (not raw list position) is
# always exercised, not just asserted once.
TABS_A_FOCUS='[{"tab_id":"w1:tA","workspace_id":"w1","focused":true,"number":1},{"tab_id":"w9:tX","workspace_id":"w9","focused":false,"number":1},{"tab_id":"w1:tB","workspace_id":"w1","focused":false,"number":2},{"tab_id":"w1:tC","workspace_id":"w1","focused":false,"number":3}]'
TABS_B_FOCUS='[{"tab_id":"w1:tA","workspace_id":"w1","focused":false,"number":1},{"tab_id":"w9:tX","workspace_id":"w9","focused":false,"number":1},{"tab_id":"w1:tB","workspace_id":"w1","focused":true,"number":2},{"tab_id":"w1:tC","workspace_id":"w1","focused":false,"number":3}]'
TABS_C_FOCUS='[{"tab_id":"w1:tA","workspace_id":"w1","focused":false,"number":1},{"tab_id":"w9:tX","workspace_id":"w9","focused":false,"number":1},{"tab_id":"w1:tB","workspace_id":"w1","focused":false,"number":2},{"tab_id":"w1:tC","workspace_id":"w1","focused":true,"number":3}]'

@test "first tab moving right computes insert_index p+2" {
  fake_herdr "$TABS_A_FOCUS"
  run "$SCRIPT" right --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "w1:tA 2" ]
}

@test "first tab moving left is a clamped no-op" {
  fake_herdr "$TABS_A_FOCUS"
  run "$SCRIPT" left --dry-run
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "middle tab moving right computes insert_index p+2" {
  fake_herdr "$TABS_B_FOCUS"
  run "$SCRIPT" right --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "w1:tB 3" ]
}

@test "middle tab moving left computes insert_index p-1" {
  fake_herdr "$TABS_B_FOCUS"
  run "$SCRIPT" left --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "w1:tB 0" ]
}

@test "last tab moving left computes insert_index p-1" {
  fake_herdr "$TABS_C_FOCUS"
  run "$SCRIPT" left --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "w1:tC 1" ]
}

@test "last tab moving right is a clamped no-op" {
  fake_herdr "$TABS_C_FOCUS"
  run "$SCRIPT" right --dry-run
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "a failed tab list exits non-zero" {
  fake_herdr_fail
  run "$SCRIPT" right --dry-run
  [ "$status" -ne 0 ]
}
