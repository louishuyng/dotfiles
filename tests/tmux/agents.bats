#!/usr/bin/env bats
# agents.sh derives state by scraping pane contents, so these tests fake the
# three commands it shells out to: `tmux` (pane list + capture), `lsappinfo`
# (which app is frontmost) and `terminal-notifier` (which logs instead of
# firing a real banner).
#
# What's worth testing is what isn't a screen marker: the busy→done edge, the
# two conditions that count as "you've seen it", and that a banner follows.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCRIPT="$REPO/terminals/tmux/scripts/agents.sh"
  export TMPDIR="$BATS_TEST_TMPDIR"
  export NOTIFY_LOG="$BATS_TEST_TMPDIR/notified"
  PATH="$BATS_TEST_TMPDIR:$PATH"

  cat > "$BATS_TEST_TMPDIR/lsappinfo" <<'EOF'
#!/opt/homebrew/bin/bash
[[ $1 == front ]] && { echo "ASN:0x0-0x1:"; exit 0; }
cat "$TMPDIR/front"
EOF
  cat > "$BATS_TEST_TMPDIR/terminal-notifier" <<'EOF'
#!/opt/homebrew/bin/bash
echo "$*" >> "$NOTIFY_LOG"
EOF
  chmod +x "$BATS_TEST_TMPDIR"/{lsappinfo,terminal-notifier}
  front Ghostty
}

# front <app-name> — what lsappinfo reports as the frontmost application.
front() { printf '"LSDisplayName"="%s"\n' "$1" > "$BATS_TEST_TMPDIR/front"; }

# fake_tmux <panes_line> <screen>
fake_tmux() {
  printf '%s\n' "$1" > "$BATS_TEST_TMPDIR/panes"
  printf '%s' "$2" > "$BATS_TEST_TMPDIR/screen"
  cat > "$BATS_TEST_TMPDIR/tmux" <<'EOF'
#!/opt/homebrew/bin/bash
case "$1" in
  list-panes) cat "$TMPDIR/panes" ;;
  capture-pane) cat "$TMPDIR/screen" ;;
esac
EOF
  chmod +x "$BATS_TEST_TMPDIR/tmux"
}

# notified — notify() detaches, so give the shim a moment to land.
notified() {
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    [[ -s ${NOTIFY_LOG:-} ]] && { cat "$NOTIFY_LOG"; return 0; }
    sleep 0.1
  done
  return 1
}

BUSY='✢ Embellishing… (1m 14s · ↓ 4.1k tokens)'
IDLE='❯ '
BLOCKED='Do you want to proceed?'

# offscreen claude pane / onscreen claude pane / offscreen shell pane
OFF='%1|claude|api|0'
ON='%1|claude|api|1'
SHELL='%2|fish|logs|0'

@test "busy pane reports busy and counts in the status segment" {
  fake_tmux "$OFF" "$BUSY"
  run "$SCRIPT" --list
  [ "$output" = $'%1\tbusy\tapi' ]
  run "$SCRIPT"
  [[ "$output" == *"#[fg=blue]"*"1"* ]]
}

@test "busy then quiet is done, and stays done across ticks" {
  fake_tmux "$OFF" "$BUSY"
  "$SCRIPT" --list
  fake_tmux "$OFF" "$IDLE"
  run "$SCRIPT" --list
  [ "$output" = $'%1\tdone\tapi' ]
  run "$SCRIPT" --list
  [ "$output" = $'%1\tdone\tapi' ]
}

@test "quiet pane never seen busy is idle, not done" {
  fake_tmux "$OFF" "$IDLE"
  run "$SCRIPT" --list
  [ "$output" = $'%1\tidle\tapi' ]
  run "$SCRIPT"
  [ "$output" = "" ]
}

@test "looking at the pane clears done" {
  fake_tmux "$OFF" "$BUSY"
  "$SCRIPT" --list
  fake_tmux "$ON" "$IDLE"
  run "$SCRIPT" --list
  [ "$output" = $'%1\tidle\tapi' ]
}

@test "the pane is on screen but the terminal isn't, so done still stands" {
  fake_tmux "$OFF" "$BUSY"
  "$SCRIPT" --list
  front "Google Chrome"
  fake_tmux "$ON" "$IDLE"
  run "$SCRIPT" --list
  [ "$output" = $'%1\tdone\tapi' ]
}

@test "permission prompt reports blocked" {
  fake_tmux "$OFF" "$BLOCKED"
  run "$SCRIPT" --list
  [ "$output" = $'%1\tblocked\tapi' ]
  run "$SCRIPT"
  [[ "$output" == *"#[fg=yellow]"*"api"* ]]
}

@test "entering blocked fires a banner with a sound, leaving it retracts" {
  fake_tmux "$OFF" "$BLOCKED"
  "$SCRIPT" --list
  run notified
  [[ "$output" == *"-group agent-%1"* ]]
  [[ "$output" == *"-sound Ping"* ]]

  : > "$NOTIFY_LOG"
  fake_tmux "$ON" "$IDLE"
  "$SCRIPT" --list
  run notified
  [[ "$output" == *"-remove agent-%1"* ]]
}

@test "finishing fires the done sound" {
  fake_tmux "$OFF" "$BUSY"
  "$SCRIPT" --list
  : > "$NOTIFY_LOG"
  fake_tmux "$OFF" "$IDLE"
  "$SCRIPT" --list
  run notified
  [[ "$output" == *"-sound Glass"* ]]
}

@test "non-agent panes are ignored" {
  fake_tmux "$SHELL" "$BUSY"
  run "$SCRIPT" --list
  [ "$output" = "" ]
}
