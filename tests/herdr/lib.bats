#!/usr/bin/env bats
# HERDR_BIN is swapped for a fake that replays fixtures, so these run with no
# herdr server and mutate nothing.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  FIX="$BATS_TEST_DIRNAME/fixtures"
  WS_ID="$(jq -r '.result.workspaces[0].workspace_id' "$FIX/workspaces.json")"
  WS_LABEL="$(jq -r '.result.workspaces[0].label' "$FIX/workspaces.json")"
  PANE_CWD="$(jq -r '.result.panes[0].cwd' "$FIX/panes.json")"
  TAB_ID="$(jq -r '.result.panes[0].tab_id' "$FIX/panes.json")"
  PANE_ID="$(jq -r '.result.panes[0].pane_id' "$FIX/panes.json")"

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
  run hd_workspace_id_by_label "$WS_LABEL"
  [ "$output" = "$WS_ID" ]
}

@test "hd_workspace_id_by_label prints nothing for an unknown label" {
  run hd_workspace_id_by_label "nope-does-not-exist"
  [ -z "$output" ]
}

@test "hd_ensure_workspace reuses rather than creates" {
  run hd_ensure_workspace "$WS_LABEL" "/tmp"
  [ "$output" = "$WS_ID" ]
  run grep -c "workspace create" "$CALLS"
  [ "$output" = "0" ]
}

@test "hd_ensure_workspace creates when absent" {
  run hd_ensure_workspace "brand-new" "/tmp/brand-new"
  [ "$output" = "wNEW" ]
  grep -q "workspace create --label brand-new --cwd /tmp/brand-new --focus" "$CALLS"
}

@test "hd_tab_id_by_cwd matches a pane cwd" {
  run hd_tab_id_by_cwd "$WS_ID" "$PANE_CWD"
  [ "$output" = "$TAB_ID" ]
}

@test "hd_tab_id_by_cwd prints nothing for an unmatched path" {
  run hd_tab_id_by_cwd "$WS_ID" "/definitely/not/open"
  [ -z "$output" ]
}

@test "hd_first_pane_id resolves a tab to its pane" {
  run hd_first_pane_id "$TAB_ID"
  [ "$output" = "$PANE_ID" ]
}

@test "hd_open_tab creates a focused tab" {
  run hd_open_tab "$WS_ID" "/tmp/x"
  [ "$output" = "wNEW:t9" ]
  grep -q "tab create --workspace $WS_ID --cwd /tmp/x --focus" "$CALLS"
}

@test "hd_split_run splits then runs the command in the new pane" {
  run hd_split_run "$PANE_ID" down 0.30 /tmp/x "ku"
  [ "$output" = "wNEW:p10" ]
  grep -q "pane split --pane $PANE_ID --direction down --ratio 0.30 --cwd /tmp/x" "$CALLS"
  grep -q "pane run wNEW:p10 ku" "$CALLS"
}
