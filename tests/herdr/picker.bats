#!/usr/bin/env bats
# --list prints the assembled list without launching fzf, so the list-building
# and dedup logic is testable non-interactively. --route exercises
# route_selection directly, so the herdr open-project routing (and the
# no-leftover-tab fix) is testable non-interactively too.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  PICKER="$REPO/terminals/sesh/sesh-picker.sh"
  FIX="$BATS_TEST_TMPDIR"

  cat > "$FIX/ws.json" <<'EOF'
{"result":{"workspaces":[{"workspace_id":"w1","label":"LX-REGASK","tab_count":2}]}}
EOF
  cat > "$FIX/panes.json" <<'EOF'
{"result":{"panes":[
 {"pane_id":"w1:p1","tab_id":"w1:t1","cwd":"/Users/x/regask/api"},
 {"pane_id":"w1:p2","tab_id":"w1:t2","cwd":"/Users/x/regask/web"}
]}}
EOF
  cat > "$FIX/tabs.json" <<'EOF'
{"result":{"tabs":[
 {"tab_id":"w1:t1","workspace_id":"w1","label":"api","number":1},
 {"tab_id":"w1:t2","workspace_id":"w1","label":"web","number":2}
]}}
EOF

  cat > "$FIX/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$FIX/calls"
case "\$1 \$2" in
  "workspace list") cat "$FIX/ws.json" ;;
  "pane list")      cat "$FIX/panes.json" ;;
  "tab list")       cat "$FIX/tabs.json" ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$FIX/herdr"
  : > "$FIX/calls"

  # zoxide stub: one path already open as a tab, one not.
  cat > "$FIX/zoxide" <<'EOF'
#!/opt/homebrew/bin/bash
printf '%s\n' /Users/x/regask/api /Users/x/personal/blog
EOF
  chmod +x "$FIX/zoxide"

  # hd_active now gives $TMUX precedence, so clear it to assert the herdr path.
  unset TMUX
  export HERDR_ENV=1 HERDR_BIN="$FIX/herdr" PATH="$FIX:$PATH"
}

@test "open tabs are listed with their tab id as the routing target" {
  run "$PICKER" --list
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\tw1:t1'* ]]
  [[ "$output" == *$'\tw1:t2'* ]]
  [[ "$output" == *"LX-REGASK"* ]]
}

@test "a zoxide path already open as a tab is not listed as a duplicate path entry" {
  run "$PICKER" --list

  # Direction matters: tab rows carry the tab_id as their target and never the
  # cwd, so a correctly-deduped project appears ONLY as a tab row. Asserting the
  # path target is ABSENT is the dedup check; asserting the tab row is PRESENT is
  # what stops this passing vacuously on empty output.
  [[ "$output" != *$'\t/Users/x/regask/api'* ]]
  [[ "$output" == *$'\tw1:t1'* ]]
}

@test "a zoxide path that is not open is listed as a path target" {
  run "$PICKER" --list
  [[ "$output" == *$'\t/Users/x/personal/blog'* ]]
}

@test "--list emits no tmux calls under herdr" {
  cat > "$FIX/tmux" <<'EOF'
#!/opt/homebrew/bin/bash
echo "TMUX-CALLED" >&2
EOF
  chmod +x "$FIX/tmux"
  run "$PICKER" --list
  [[ "$output" != *"TMUX-CALLED"* ]]
}

@test "outside herdr, --list falls back to tmux windows" {
  cat > "$FIX/tmux" <<'EOF'
#!/opt/homebrew/bin/bash
[[ "$1" == "list-windows" ]] && echo "legacy:1 oldwin"
EOF
  chmod +x "$FIX/tmux"
  run env -u HERDR_ENV "$PICKER" --list
  [[ "$output" == *"legacy:1"* ]]
}

# --route exercises route_selection's herdr branches directly, against a
# herdr fake that also handles workspace/tab create+rename, so the
# no-leftover-"1"-tab fix (hd_open_project) is verified at the point the
# user hit the bug: opening a project whose sesh workspace doesn't exist yet.

@test "routing into a fresh sesh root creates one tab, not a leftover numbered one" {
  cat > "$FIX/sesh.toml" <<EOF
[[session]]
name = "widgets"
path = "$FIX/widgets"
EOF
  cat > "$FIX/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$FIX/calls"
case "\$1 \$2" in
  "workspace list")   echo '{"result":{"workspaces":[]}}' ;;
  "workspace create") echo '{"result":{"workspace":{"workspace_id":"wNEW"},"tab":{"tab_id":"wNEW:t1"}}}' ;;
  *)                  echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$FIX/herdr"

  SESH_TOML="$FIX/sesh.toml" run "$PICKER" --route "$FIX/widgets"
  [ "$status" -eq 0 ]
  grep -q -- "workspace create --label widgets --cwd $FIX/widgets --focus" "$FIX/calls"
  grep -q "tab rename wNEW:t1 widgets" "$FIX/calls"
  # The bug this guards: a second, numerically-labelled tab left at the root.
  ! grep -q "tab create" "$FIX/calls"
}

@test "routing to a subdirectory of an existing sesh workspace opens a tab in it, not a new workspace" {
  # A real, writable root: hd_open_tab mkdir -p's the target for real.
  cat > "$FIX/sesh.toml" <<EOF
[[session]]
name = "LX-REGASK"
path = "$FIX/regask"
EOF
  cat > "$FIX/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$FIX/calls"
case "\$1 \$2" in
  "workspace list") cat "$FIX/ws.json" ;;
  "pane list")      echo '{"result":{"panes":[]}}' ;;
  "tab create")     echo '{"result":{"tab":{"tab_id":"w1:tNEW"}}}' ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$FIX/herdr"

  SESH_TOML="$FIX/sesh.toml" run "$PICKER" --route "$FIX/regask/newsvc"
  [ "$status" -eq 0 ]
  grep -q -- "tab create --workspace w1 --cwd $FIX/regask/newsvc --label newsvc --focus" "$FIX/calls"
  ! grep -q "workspace create" "$FIX/calls"
}

@test "routing to a path under no known sesh root creates a labelled standalone workspace" {
  cat > "$FIX/sesh.toml" <<EOF
[[session]]
name = "LX-REGASK"
path = "/Users/x/regask"
EOF
  cat > "$FIX/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$FIX/calls"
echo '{"result":{}}'
EOF
  chmod +x "$FIX/herdr"

  SESH_TOML="$FIX/sesh.toml" run "$PICKER" --route "$FIX/standalone-proj"
  [ "$status" -eq 0 ]
  # Without --label this would land in the sidebar as a bare number.
  grep -q -- "--label standalone-proj" "$FIX/calls"
  grep -q -- "workspace create" "$FIX/calls"
}
