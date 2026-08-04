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

  run env HERDR_ENV=1 HERDR_BIN="$BATS_TEST_TMPDIR/herdr" \
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
