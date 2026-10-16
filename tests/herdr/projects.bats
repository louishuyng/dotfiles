#!/usr/bin/env bats

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export CALLS="$BATS_TEST_TMPDIR/calls"
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr"
  export PANES='{"result":{"panes":[]}}'
  cat > "$HERDR_BIN" <<'EOF'
#!/bin/bash
echo "$*" >> "$CALLS"
case "$*" in
  'workspace list')
    [[ "${FAIL_LIST:-}" != 1 ]] || exit 1
    echo "${WORKSPACES}"
    ;;
  'workspace create '*) echo '{"result":{"workspace":{"workspace_id":"new-projects"},"tab":{"tab_id":"new-projects:t1"}}}' ;;
  'plugin pane open '*) [[ "${FAIL_OPEN:-}" != 1 ]] ;;
  'workspace focus '*) [[ "${FAIL_FOCUS:-}" != 1 ]] ;;
  'pane list '*) echo "$PANES" ;;
esac
EOF
  chmod +x "$HERDR_BIN"
}

@test "new Projects workspace keeps only the board tab" {
  export WORKSPACES='{"result":{"workspaces":[{"label":"Dev","workspace_id":"dev"}]}}'
  export PANES='{"result":{"panes":[{"label":"Work board","tab_id":"new-projects:t2"}]}}'
  run bash "$REPO/terminals/herdr/scripts/projects.sh"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "$(printf '%s\n' 'workspace list' "workspace create --cwd $HOME --label Projects --no-focus" 'plugin pane open --plugin herdr-projects --entrypoint board --placement tab --workspace new-projects --focus' 'pane list --workspace new-projects' 'tab rename new-projects:t2 board' 'tab close new-projects:t1' 'workspace focus new-projects' 'tab focus new-projects:t2')" ]
}

@test "keeps the initial tab if opening the board fails" {
  export WORKSPACES='{"result":{"workspaces":[]}}'
  export FAIL_OPEN=1
  run bash "$REPO/terminals/herdr/scripts/projects.sh"
  [ "$status" -ne 0 ]
  ! grep -q '^tab close ' "$CALLS"
}

@test "reuses the Projects workspace" {
  export WORKSPACES='{"result":{"workspaces":[{"label":"Projects","workspace_id":"existing"}]}}'
  run bash "$REPO/terminals/herdr/scripts/projects.sh"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "$(printf '%s\n' 'workspace list' 'workspace focus existing' 'pane list --workspace existing' 'plugin action invoke herdr-projects.open')" ]
}

@test "focuses the existing board without toggling it away" {
  export WORKSPACES='{"result":{"workspaces":[{"label":"Projects","workspace_id":"existing"}]}}'
  export PANES='{"result":{"panes":[{"label":"Work board","pane_id":"existing:p2"}]}}'
  run bash "$REPO/terminals/herdr/scripts/projects.sh"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "$(printf '%s\n' 'workspace list' 'workspace focus existing' 'pane list --workspace existing' 'plugin pane focus existing:p2')" ]
}

@test "does not create a workspace after a failed lookup" {
  export FAIL_LIST=1
  run bash "$REPO/terminals/herdr/scripts/projects.sh"
  [ "$status" -ne 0 ]
  [ "$(cat "$CALLS")" = 'workspace list' ]
}

@test "does not open the board after focus fails" {
  export WORKSPACES='{"result":{"workspaces":[{"label":"Projects","workspace_id":"existing"}]}}'
  export FAIL_FOCUS=1
  run bash "$REPO/terminals/herdr/scripts/projects.sh"
  [ "$status" -ne 0 ]
  [ "$(tail -1 "$CALLS")" = 'workspace focus existing' ]
}
