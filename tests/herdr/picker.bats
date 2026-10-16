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
[[ "\${FAIL_CALL:-}" == "\$1 \$2" ]] && exit 7
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
  export FIX
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
case "\$1 \$2" in
  "workspace list") echo '{"result":{"workspaces":[]}}' ;;
  "workspace create") echo '{"result":{"tab":{"tab_id":"wNEW:t1"}}}' ;;
  *) echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$FIX/herdr"

  SESH_TOML="$FIX/sesh.toml" run "$PICKER" --route "$FIX/standalone-proj"
  [ "$status" -eq 0 ]
  # Without --label this would land in the sidebar as a bare number.
  grep -q -- "--label standalone-proj" "$FIX/calls"
  grep -q -- "workspace create" "$FIX/calls"
}

picker_actions() {
  cat > "$FIX/fzf" <<'EOF'
#!/opt/homebrew/bin/bash
cat >/dev/null
printf '%s\n' "$@" >> "$FIX/fzf.args"
n=$(cat "$FIX/fzf.count" 2>/dev/null || echo 0)
n=$((n+1))
echo "$n" > "$FIX/fzf.count"
[[ -f "$FIX/answer.$n" ]] || exit 130
cat "$FIX/answer.$n"
EOF
  chmod +x "$FIX/fzf"
}

@test "failed list calls never expose a partial project list" {
  for call in 'workspace list' 'pane list' 'tab list'; do
    run env FAIL_CALL="$call" "$PICKER" --list
    [ "$status" -eq 2 ]
    [ "$output" = 'Could not list projects.' ]
  done
  echo '{"error":"unreachable"}' > "$FIX/ws.json"
  run "$PICKER" --list
  [ "$status" -eq 2 ]
}

@test "failed lookups prevent creation and propagate status through route cleanup" {
  echo '' > "$FIX/sesh.toml"
  for response in '{"error":"unreachable"}' 'not json'; do
    echo "$response" > "$FIX/ws.json"
    run env SESH_TOML="$FIX/sesh.toml" "$PICKER" --route "$FIX/new"
    [ "$status" -eq 2 ]
    ! grep -q 'create' "$FIX/calls"
  done
  run env FAIL_CALL='workspace list' SESH_TOML="$FIX/sesh.toml" "$PICKER" --route "$FIX/new"
  [ "$status" -eq 2 ]
  ! grep -q 'create' "$FIX/calls"
}

@test "failed focus and create preserve nonzero status" {
  run env FAIL_CALL='tab focus' "$PICKER" --route w1:t1
  [ "$status" -eq 7 ]
  echo '{"result":{"workspaces":[]}}' > "$FIX/ws.json"
  run env FAIL_CALL='workspace create' "$PICKER" --route "$FIX/new"
  [ "$status" -eq 2 ]
}

@test "selection cancellation sends no mutation" {
  picker_actions
  run "$PICKER"
  [ "$status" -eq 0 ]
  ! grep -Eq 'focus|create|close' "$FIX/calls"
}

@test "close confirmation names the tab and cancellation sends no close" {
  picker_actions
  printf 'Cancel\n' > "$FIX/answer.1"
  run "$PICKER" --close w1:t1 'widgets:1 api'
  [ "$status" -eq 0 ]
  grep -qF 'Close tab: widgets:1 api?' "$FIX/fzf.args"
  ! grep -q 'tab close' "$FIX/calls"
  rm "$FIX/answer.1" "$FIX/fzf.count"
  run "$PICKER" --close w1:t1 'widgets:1 api'
  [ "$status" -eq 0 ]
  ! grep -q 'tab close' "$FIX/calls"
}

@test "confirmed close sends one request and preserves failure" {
  picker_actions
  printf 'Close\n' > "$FIX/answer.1"
  run env FAIL_CALL='tab close' "$PICKER" --close w1:t1
  [ "$status" -eq 7 ]
  [ "$(grep -c 'tab close w1:t1' "$FIX/calls")" -eq 1 ]
}

@test "focus failure stays visible in picker with retry and cancel" {
  picker_actions
  printf 'enter\napi\tw1:t1\n' > "$FIX/answer.1"
  run env FAIL_CALL='tab focus' "$PICKER"
  [ "$status" -eq 7 ]
  grep -qF 'Could not open/focus project. Enter retry' "$FIX/fzf.args"
  grep -qF 'Ctrl+R retry list' "$FIX/fzf.args"
  grep -qF 'Ctrl+P preview' "$FIX/fzf.args"
}

@test "list failure stays visible and retry repeats the lookup" {
  picker_actions
  printf 'ctrl-r\n' > "$FIX/answer.1"
  run env FAIL_CALL='workspace list' "$PICKER"
  [ "$status" -eq 2 ]
  grep -qF 'Could not list projects.' "$FIX/fzf.args"
  [ "$(grep -c 'workspace list' "$FIX/calls")" -eq 2 ]
}

@test "close failure stays visible in picker" {
  picker_actions
  printf 'ctrl-d\napi\tw1:t1\n' > "$FIX/answer.1"
  printf 'Close\n' > "$FIX/answer.2"
  run env FAIL_CALL='tab close' "$PICKER"
  [ "$status" -eq 7 ]
  grep -qF 'Could not close tab. Ctrl+D retry' "$FIX/fzf.args"
}

@test "successful selection focuses once and exits" {
  picker_actions
  printf 'enter\napi\tw1:t1\n' > "$FIX/answer.1"
  run "$PICKER"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'tab focus w1:t1' "$FIX/calls")" -eq 1 ]
  ! grep -q 'create' "$FIX/calls"
}

fake_tmux() {
  cat > "$FIX/tmux" <<'EOF'
#!/opt/homebrew/bin/bash
echo "$*" >> "$FIX/tmux.calls"
[[ "${FAIL_TMUX:-}" == "$1" ]] && exit 8
case "$1" in
  list-sessions) echo widgets ;;
  list-windows) printf '1 %s/widgets/api\n' "$FIX" ;;
esac
exit 0
EOF
  chmod +x "$FIX/tmux"
  export TMUX=fake
}

@test "nested tmux routes focus, confirmed close, and failures to tmux" {
  fake_tmux
  picker_actions
  run "$PICKER" --route widgets:1
  [ "$status" -eq 0 ]
  grep -q 'switch-client -t widgets:1' "$FIX/tmux.calls"
  run env FAIL_TMUX=switch-client "$PICKER" --route widgets:1
  [ "$status" -eq 8 ]
  printf 'Close\n' > "$FIX/answer.1"
  run env FAIL_TMUX=kill-window "$PICKER" --close widgets:1
  [ "$status" -eq 8 ]
  ! test -s "$FIX/calls"
}

@test "tmux lookup failure prevents creation and existing paths focus" {
  fake_tmux
  printf '[[session]]\nname = "widgets"\npath = "%s/widgets"\n' "$FIX" > "$FIX/sesh.toml"
  run env SESH_TOML="$FIX/sesh.toml" FAIL_TMUX=list-windows "$PICKER" --route "$FIX/widgets/api"
  [ "$status" -eq 2 ]
  ! grep -q 'new-' "$FIX/tmux.calls"
  run env SESH_TOML="$FIX/sesh.toml" "$PICKER" --route "$FIX/widgets/api"
  [ "$status" -eq 0 ]
  grep -q 'switch-client -t widgets:1' "$FIX/tmux.calls"
  ! grep -q 'new-' "$FIX/tmux.calls"
}


@test "create failure stays visible without duplicate attempts" {
  picker_actions
  echo '{"result":{"workspaces":[]}}' > "$FIX/ws.json"
  printf 'enter\nnew\t%s/new\n' "$FIX" > "$FIX/answer.1"
  run env FAIL_CALL='workspace create' "$PICKER"
  [ "$status" -eq 2 ]
  grep -qF 'Could not open/focus project.' "$FIX/fzf.args"
  [ "$(grep -c 'workspace create' "$FIX/calls")" -eq 1 ]
}

@test "tmux list failure stays visible and cancel closes nothing" {
  fake_tmux
  picker_actions
  run env FAIL_TMUX=list-windows "$PICKER"
  [ "$status" -eq 2 ]
  grep -qF 'Could not list projects.' "$FIX/fzf.args"
  ! grep -Eq 'new-|kill-|switch-client' "$FIX/tmux.calls"
}

@test "picker cleans temporary files after cancellation" {
  picker_actions
  mkdir "$FIX/tmp"
  run env TMPDIR="$FIX/tmp" "$PICKER"
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$FIX/tmp")" ]
}


@test "failed pane lookup prevents a new tab" {
  printf '[[session]]\nname = "LX-REGASK"\npath = "%s/widgets"\n' "$FIX" > "$FIX/sesh.toml"
  echo '{"error":"unreachable"}' > "$FIX/panes.json"
  run env SESH_TOML="$FIX/sesh.toml" "$PICKER" --route "$FIX/widgets/api"
  [ "$status" -eq 2 ]
  ! grep -q create "$FIX/calls"
}

@test "confirmation tool failure preserves an error without closing" {
  cat > "$FIX/fzf" <<'EOF'
#!/opt/homebrew/bin/bash
cat >/dev/null
exit 2
EOF
  chmod +x "$FIX/fzf"
  run "$PICKER" --close w1:t1
  [ "$status" -eq 2 ]
  ! grep -q close "$FIX/calls"
}

@test "tmux opens one new window without a fallback on failed creation" {
  fake_tmux
  printf '[[session]]\nname = "widgets"\npath = "%s/widgets"\n' "$FIX" > "$FIX/sesh.toml"
  run env SESH_TOML="$FIX/sesh.toml" "$PICKER" --route "$FIX/widgets/new"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'new-window' "$FIX/tmux.calls")" -eq 1 ]
  ! grep -q 'new-session' "$FIX/tmux.calls"
  run env SESH_TOML="$FIX/sesh.toml" FAIL_TMUX=new-window "$PICKER" --route "$FIX/widgets/new"
  [ "$status" -eq 2 ]
  ! grep -q 'new-session' "$FIX/tmux.calls"
}
