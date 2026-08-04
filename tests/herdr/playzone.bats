#!/usr/bin/env bats

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  source "$REPO/terminals/sesh/roots.sh"
}

@test "parse_roots extracts named roots from sesh.toml" {
  SESH_TOML="$REPO/terminals/sesh/sesh.toml"
  parse_roots "$BATS_TEST_TMPDIR/roots.tsv"
  # Lower bound, not an exact count: this tests the parser, not the project
  # list, so adding a sesh entry must not fail the suite.
  run wc -l < "$BATS_TEST_TMPDIR/roots.tsv"
  [ "$output" -ge 4 ]
  # Tilde expansion and the name->path pairing are what actually matter.
  grep -qF "LX-REGASK	$HOME/LX14/repository/github.com/regask" "$BATS_TEST_TMPDIR/roots.tsv"
}

@test "parse_roots handles a synthetic toml exactly" {
  cat > "$BATS_TEST_TMPDIR/sesh.toml" <<'EOF'
[[session]]
name = "alpha"
path = "~/alpha"

[[session]]
name = "beta"
path = "/abs/beta"
EOF
  SESH_TOML="$BATS_TEST_TMPDIR/sesh.toml" parse_roots "$BATS_TEST_TMPDIR/s.tsv"
  run cat "$BATS_TEST_TMPDIR/s.tsv"
  [ "${lines[0]}" = "alpha	$HOME/alpha" ]
  [ "${lines[1]}" = "beta	/abs/beta" ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "playzone lib routes to herdr when HERDR_ENV=1" {
  CALLS="$BATS_TEST_TMPDIR/calls"; : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$CALLS"
case "\$1 \$2" in
  "workspace list") echo '{"result":{"workspaces":[]}}' ;;
  "pane list")      echo '{"result":{"panes":[]}}' ;;
  "workspace create") echo '{"result":{"workspace":{"workspace_id":"wZ"},"tab":{"tab_id":"wZ:t1"},"root_pane":{"pane_id":"wZ:p1"}}}' ;;
  "tab create")     echo '{"result":{"tab":{"tab_id":"wZ:t2"},"root_pane":{"pane_id":"wZ:p2"}}}' ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"

  # hd_active now gives $TMUX precedence, so clear it to assert the herdr path.
  run env -u TMUX HERDR_ENV=1 HERDR_BIN="$BATS_TEST_TMPDIR/herdr" \
      SESH_TOML="$REPO/terminals/sesh/sesh.toml" \
      bash -c "source '$REPO/terminals/playzones/lib.sh'; pz_ensure_session LX-REGASK"
  [ "$status" -eq 0 ]
  grep -q "workspace create --label LX-REGASK" "$CALLS"
  ! grep -q "tmux" "$CALLS"
}

@test "playzone lib does not call herdr outside a herdr pane" {
  CALLS="$BATS_TEST_TMPDIR/calls2"; : > "$CALLS"
  printf '#!/opt/homebrew/bin/bash\necho "$*" >> "%s"\n' "$CALLS" > "$BATS_TEST_TMPDIR/herdr"
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  run env -u HERDR_ENV HERDR_BIN="$BATS_TEST_TMPDIR/herdr" PATH="/usr/bin:/bin" \
      bash -c "source '$REPO/terminals/playzones/lib.sh'; pz_ensure_session LX-REGASK 2>/dev/null || true"
  [ ! -s "$CALLS" ]
}

# Shared fake for the pz_open_or_split herdr-branch tests. panes.json is written
# per-test so each can choose whether a tab already matches the target cwd.
setup_hd_fake() {
  CALLS="$BATS_TEST_TMPDIR/calls"; : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/herdr" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$CALLS"
case "\$1 \$2" in
  "workspace list") echo '{"result":{"workspaces":[{"workspace_id":"w1","label":"LX-REGASK"}]}}' ;;
  "pane list")      cat "$BATS_TEST_TMPDIR/panes.json" ;;
  "tab create")     echo '{"result":{"tab":{"tab_id":"w1:tNEW"},"root_pane":{"pane_id":"w1:pNEW"}}}' ;;
  "pane split")     echo '{"result":{"pane":{"pane_id":"w1:pSPLIT"}}}' ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr"
  # hd_active now gives $TMUX precedence, so clear it to assert the herdr path.
  unset TMUX
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr" HERDR_ENV=1
  source "$REPO/terminals/playzones/lib.sh"
}

@test "pz_open_or_split splits an existing tab with the inverted ratio" {
  setup_hd_fake
  local cwd="$BATS_TEST_TMPDIR/existing"
  printf '{"result":{"panes":[{"pane_id":"w1:p1","tab_id":"w1:t1","cwd":"%s"}]}}\n' "$cwd" > "$BATS_TEST_TMPDIR/panes.json"

  run pz_open_or_split LX-REGASK "ku" "$cwd" "-v" "30%"
  [ "$status" -eq 0 ]
  grep -q "tab focus w1:t1" "$CALLS"
  # 30% for the NEW pane means --ratio 0.70: --ratio sizes the EXISTING pane.
  grep -q -- "pane split --pane w1:p1 --direction down --ratio 0.70 --cwd $cwd" "$CALLS"
  grep -q "pane run w1:pSPLIT ku" "$CALLS"
}

@test "pz_open_or_split creates a tab and runs the command when none matches" {
  setup_hd_fake
  local cwd="$BATS_TEST_TMPDIR/absent"
  # cwd deliberately does NOT match, so the absent arm is taken; the pane's
  # tab_id DOES match what `tab create` returns, so hd_first_pane_id resolves it.
  printf '{"result":{"panes":[{"pane_id":"w1:pNEW","tab_id":"w1:tNEW","cwd":"/somewhere/else"}]}}\n' > "$BATS_TEST_TMPDIR/panes.json"

  run pz_open_or_split LX-REGASK "ku" "$cwd" "-v" "30%"
  [ "$status" -eq 0 ]
  # Tab is labelled with the folder name, not herdr's default tab number.
  grep -q -- "tab create --workspace w1 --cwd $cwd --label absent --focus" "$CALLS"
  grep -q "pane run w1:pNEW ku" "$CALLS"
  # This arm must not split — the new tab's root pane runs the command directly.
  ! grep -q "pane split" "$CALLS"
}

@test "pz_open_or_split maps tmux -h to herdr --direction right" {
  setup_hd_fake
  local cwd="$BATS_TEST_TMPDIR/hsplit"
  printf '{"result":{"panes":[{"pane_id":"w1:p1","tab_id":"w1:t1","cwd":"%s"}]}}\n' "$cwd" > "$BATS_TEST_TMPDIR/panes.json"

  run pz_open_or_split LX-REGASK "ku" "$cwd" "-h" "50%"
  [ "$status" -eq 0 ]
  grep -q -- "--direction right --ratio 0.50" "$CALLS"
}

@test "pz_open_or_split propagates status 2 when a herdr lookup fails" {
  local calls="$BATS_TEST_TMPDIR/calls-fail"; : > "$calls"
  cat > "$BATS_TEST_TMPDIR/herdr-fail" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$calls"
exit 1
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr-fail"
  # hd_active now gives $TMUX precedence, so clear it to assert the herdr path.
  unset TMUX
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr-fail" HERDR_ENV=1
  source "$REPO/terminals/playzones/lib.sh"

  run pz_open_or_split LX-REGASK "ku" "$BATS_TEST_TMPDIR/failcwd" "-v" "30%"
  [ "$status" -eq 2 ]
  ! grep -q "pane split" "$calls"
}

@test "pz_open_or_split propagates a failed tab focus instead of splitting blind" {
  local calls="$BATS_TEST_TMPDIR/calls-focusfail"; : > "$calls"
  local cwd="$BATS_TEST_TMPDIR/focusfail"
  cat > "$BATS_TEST_TMPDIR/herdr-focusfail" <<EOF
#!/opt/homebrew/bin/bash
echo "\$*" >> "$calls"
case "\$1 \$2" in
  "workspace list") echo '{"result":{"workspaces":[{"workspace_id":"w1","label":"LX-REGASK"}]}}' ;;
  "pane list")      echo '{"result":{"panes":[{"pane_id":"w1:p1","tab_id":"w1:t1","cwd":"$cwd"}]}}' ;;
  "tab focus")      exit 1 ;;
  *)                echo '{"result":{}}' ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/herdr-focusfail"
  # hd_active now gives $TMUX precedence, so clear it to assert the herdr path.
  unset TMUX
  export HERDR_BIN="$BATS_TEST_TMPDIR/herdr-focusfail" HERDR_ENV=1
  source "$REPO/terminals/playzones/lib.sh"

  run pz_open_or_split LX-REGASK "ku" "$cwd" "-v" "30%"
  [ "$status" -eq 2 ]
  # Must not split a tab it failed to focus.
  ! grep -q "pane split" "$calls"
}
