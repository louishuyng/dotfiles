#!/usr/bin/env bats
# pane-swap.sh computes ordinal position from `pane list`, which spans every
# tab and workspace, so these tests exercise the index arithmetic via
# --dry-run against fixtures that interleave other tabs/workspaces among the
# target tab's panes. A naive unfiltered index would land on one of those
# interlopers instead of the real neighbour, which is what makes the
# fixtures discriminate a missing tab_id filter rather than merely assert it.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCRIPT="$REPO/terminals/herdr/scripts/pane-swap.sh"
}

# fake_herdr <panes_json>
#   <panes_json> becomes the value of .result.panes for `pane list`.
fake_herdr() {
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo '{"result":{"panes":$1}}'
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

# Tab t1 (workspace w1) holds [p1,p2,p3] in visual order. a1 (tab t9) and
# x1/x2 (tab t2, also workspace w1) sit at the raw indices a naive,
# unfiltered computation would consult, so a missing tab_id filter would
# resolve to a1/x1/x2 instead of the real p1/p2/p3 neighbours.
PANES_P1_FOCUS='[{"pane_id":"a1","tab_id":"t9","workspace_id":"w9","focused":false,"cwd":"/a"},{"pane_id":"p1","tab_id":"t1","workspace_id":"w1","focused":true,"cwd":"/p"},{"pane_id":"x1","tab_id":"t2","workspace_id":"w1","focused":false,"cwd":"/x"},{"pane_id":"p2","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"},{"pane_id":"x2","tab_id":"t2","workspace_id":"w1","focused":false,"cwd":"/x"},{"pane_id":"p3","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"}]'
PANES_P2_FOCUS='[{"pane_id":"a1","tab_id":"t9","workspace_id":"w9","focused":false,"cwd":"/a"},{"pane_id":"p1","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"},{"pane_id":"x1","tab_id":"t2","workspace_id":"w1","focused":false,"cwd":"/x"},{"pane_id":"p2","tab_id":"t1","workspace_id":"w1","focused":true,"cwd":"/p"},{"pane_id":"x2","tab_id":"t2","workspace_id":"w1","focused":false,"cwd":"/x"},{"pane_id":"p3","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"}]'
PANES_P3_FOCUS='[{"pane_id":"a1","tab_id":"t9","workspace_id":"w9","focused":false,"cwd":"/a"},{"pane_id":"p1","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"},{"pane_id":"x1","tab_id":"t2","workspace_id":"w1","focused":false,"cwd":"/x"},{"pane_id":"p2","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"},{"pane_id":"x2","tab_id":"t2","workspace_id":"w1","focused":false,"cwd":"/x"},{"pane_id":"p3","tab_id":"t1","workspace_id":"w1","focused":true,"cwd":"/p"}]'
PANES_NO_FOCUS='[{"pane_id":"a1","tab_id":"t9","workspace_id":"w9","focused":false,"cwd":"/a"},{"pane_id":"p1","tab_id":"t1","workspace_id":"w1","focused":false,"cwd":"/p"}]'

@test "first pane, next swaps with the second" {
  fake_herdr "$PANES_P1_FOCUS"
  run "$SCRIPT" next --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "p1 p2" ]
}

@test "middle pane, prev swaps with the first" {
  fake_herdr "$PANES_P2_FOCUS"
  run "$SCRIPT" prev --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "p2 p1" ]
}

@test "middle pane, next swaps with the third" {
  fake_herdr "$PANES_P2_FOCUS"
  run "$SCRIPT" next --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "p2 p3" ]
}

@test "last pane, prev swaps with the second" {
  fake_herdr "$PANES_P3_FOCUS"
  run "$SCRIPT" prev --dry-run
  [ "$status" -eq 0 ]
  [ "$output" = "p3 p2" ]
}

@test "first pane, prev is a no-op" {
  fake_herdr "$PANES_P1_FOCUS"
  run "$SCRIPT" prev --dry-run
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "last pane, next is a no-op" {
  fake_herdr "$PANES_P3_FOCUS"
  run "$SCRIPT" next --dry-run
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "a failed pane list exits 2" {
  fake_herdr_fail
  run "$SCRIPT" next --dry-run
  [ "$status" -eq 2 ]
}

@test "no focused pane in the list exits 2" {
  fake_herdr "$PANES_NO_FOCUS"
  run "$SCRIPT" next --dry-run
  [ "$status" -eq 2 ]
}
