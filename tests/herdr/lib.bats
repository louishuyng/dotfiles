#!/usr/bin/env bats
# HERDR_BIN is swapped for a fake that replays fixtures, so these run with no
# herdr server and mutate nothing. Fixtures are hand-authored (not captured
# from a live server) so the repo never carries real session metadata, and so
# the expected values below are literals, not derived from the fixtures via
# jq — a fixture edit that changes behavior should fail a test, not silently
# redefine what's asserted.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  FIX="$BATS_TEST_DIRNAME/fixtures"

  # Fake herdr: replay fixtures for reads, log mutations to $CALLS.
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$CALLS"
case "\$1 \$2" in
  "workspace list") cat "$FIX/workspaces.json" ;;
  "pane list")      cat "$FIX/panes.json" ;;
  "workspace create") echo '{"result":{"workspace":{"workspace_id":"wNEW"},"tab":{"tab_id":"wNEW:t1"},"root_pane":{"pane_id":"wNEW:p1"}}}' ;;
  "tab create")     echo '{"result":{"tab":{"tab_id":"wNEW:t9"},"root_pane":{"pane_id":"wNEW:p9"}}}' ;;
  "pane split")     echo '{"result":{"pane":{"pane_id":"wNEW:p10"}}}' ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr"
  source "$REPO/terminals/herdr/lib.sh"
}

@test "hd_active is true only inside a herdr pane" {
  export HERDR_ENV=1
  run hd_active
  [ "$status" -eq 0 ]

  unset HERDR_ENV
  run hd_active
  [ "$status" -ne 0 ]

  # A value other than 1 must not count as being inside herdr.
  export HERDR_ENV=0
  run hd_active
  [ "$status" -ne 0 ]
}

@test "hd_workspace_id_by_label finds an existing workspace" {
  run hd_workspace_id_by_label "LX-REGASK"
  [ "$output" = "w1" ]
}

@test "hd_workspace_id_by_label finds a second, distinct workspace" {
  run hd_workspace_id_by_label "dotfiles"
  [ "$output" = "w2" ]
}

@test "hd_workspace_id_by_label prints nothing for an unknown label" {
  run hd_workspace_id_by_label "nope-does-not-exist"
  [ -z "$output" ]
}

@test "hd_ensure_workspace reuses rather than creates" {
  run hd_ensure_workspace "LX-REGASK" "/synthetic/regask"
  [ "$output" = "w1" ]
  run grep -c "workspace create" "$CALLS"
  [ "$output" = "0" ]
}

@test "hd_ensure_workspace creates when absent" {
  run hd_ensure_workspace "brand-new" "/tmp/brand-new"
  [ "$output" = "wNEW" ]
  grep -q "workspace create --label brand-new --cwd /tmp/brand-new --focus" "$CALLS"
}

@test "hd_tab_id_by_cwd matches a pane cwd" {
  run hd_tab_id_by_cwd "w1" "/synthetic/regask/api"
  [ "$output" = "w1:t1" ]
}

@test "hd_tab_id_by_cwd matches a second, distinct tab" {
  run hd_tab_id_by_cwd "w1" "/synthetic/regask/web"
  [ "$output" = "w1:t2" ]
}

@test "hd_tab_id_by_cwd prints nothing for an unmatched path" {
  run hd_tab_id_by_cwd "w1" "/synthetic/nope"
  [ -z "$output" ]
}

@test "hd_first_pane_id resolves a tab to its first pane" {
  # w1:t1 has two panes (w1:p1, w1:p2) in the fixture specifically so this
  # proves "first" means first, not just "a match somewhere in the tab".
  run hd_first_pane_id "w1:t1"
  [ "$output" = "w1:p1" ]
}

@test "hd_open_tab creates a focused tab" {
  run hd_open_tab "w1" "/tmp/x"
  [ "$output" = "wNEW:t9" ]
  grep -q "tab create --workspace w1 --cwd /tmp/x --focus" "$CALLS"
}

@test "hd_split_run splits then runs the command in the new pane" {
  run hd_split_run "w1:p1" down 0.30 /tmp/x "ku"
  [ "$output" = "wNEW:p10" ]
  grep -q "pane split --pane w1:p1 --direction down --ratio 0.30 --cwd /tmp/x" "$CALLS"
  grep -q "pane run wNEW:p10 ku" "$CALLS"
}

@test "a failed herdr call is distinguishable from a legitimate no-match" {
  cat > "$BATS_TEST_TMPDIR/herdr-fail" <<'FAIL'
#!/opt/homebrew/bin/bash
exit 1
FAIL
  chmod +x "$BATS_TEST_TMPDIR/herdr-fail"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr-fail"

  run hd_workspace_id_by_label "LX-REGASK"
  [ "$status" -eq 2 ]
  run hd_tab_id_by_cwd w1 /synthetic/regask/api
  [ "$status" -eq 2 ]
  run hd_first_pane_id w1:t1
  [ "$status" -eq 2 ]
}

@test "hd_ensure_workspace does not create a duplicate when the lookup fails" {
  local calls="$BATS_TEST_TMPDIR/calls-dup"
  : > "$calls"
  cat > "$BATS_TEST_TMPDIR/herdr-listfail" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$calls"
case "\$1 \$2" in
  "workspace list")   exit 1 ;;
  "workspace create") echo '{"result":{"workspace":{"workspace_id":"wDUP"}}}' ;;
  *)                  echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr-listfail"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr-listfail"

  run hd_ensure_workspace "LX-REGASK" /tmp/dup-guard
  [ "$status" -eq 2 ]
  # The regression this guards: a failed lookup must never reach `workspace create`.
  ! grep -q "workspace create" "$calls"
}

@test "hd_split_run returns 3 when the split succeeds but the command fails" {
  local calls="$BATS_TEST_TMPDIR/calls-runfail"
  : > "$calls"
  cat > "$BATS_TEST_TMPDIR/herdr-runfail" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$calls"
case "\$1 \$2" in
  "pane split") echo '{"result":{"pane":{"pane_id":"wNEW:p10"}}}' ;;
  "pane run")   exit 1 ;;
  *)            echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr-runfail"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr-runfail"

  run hd_split_run w1:p1 down 0.30 /tmp/split-runfail "ku"
  [ "$status" -eq 3 ]
  grep -q "pane split" "$calls"
  grep -q "pane run wNEW:p10 ku" "$calls"
}

@test "malformed herdr output is a failed call, not a no-match" {
  cat > "$BATS_TEST_TMPDIR/herdr-garbage" <<'GARBAGE'
#!/opt/homebrew/bin/bash
echo "this is not json at all"
exit 0
GARBAGE
  chmod +x "$BATS_TEST_TMPDIR/herdr-garbage"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr-garbage"

  # bats folds stderr into $output, so asserting it is empty also proves no jq
  # parse error leaked — which is what would garble the fzf popup in Task 6.
  run hd_workspace_id_by_label "LX-REGASK"
  [ "$status" -eq 2 ]
  [ -z "$output" ]

  run hd_tab_id_by_cwd w1 /synthetic/regask/api
  [ "$status" -eq 2 ]
  [ -z "$output" ]

  run hd_first_pane_id w1:t1
  [ "$status" -eq 2 ]
  [ -z "$output" ]
}
