#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../../terminals/tern/zed-project.sh"
  export CALLS="$BATS_TEST_TMPDIR/zed-args"
  export PATH="$BATS_TEST_TMPDIR:$PATH"
  REPO="$BATS_TEST_TMPDIR/project with spaces"
  git init -q "$REPO"
  mkdir -p "$REPO/src/nested"
  REPO=$(cd "$REPO" && pwd -P)
  touch "$REPO/src/nested/file with spaces.lua"
  cat > "$BATS_TEST_TMPDIR/zed" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$CALLS"
EOF
  chmod +x "$BATS_TEST_TMPDIR/zed"
}

@test "a nested file opens the repository root and selects the file" {
  run bash "$SCRIPT" "$REPO/src/nested/file with spaces.lua"
  [ "$status" -eq 0 ]
  mapfile -t args < "$CALLS"
  [ "${args[0]}" = --wait ]
  [ "${args[1]}" = "$REPO" ]
  [ "${args[2]}" = "$REPO/src/nested/file with spaces.lua" ]
  [ "${#args[@]}" -eq 3 ]
}

@test "a directory inside a repository opens only the project root" {
  run bash "$SCRIPT" "$REPO/src/nested"
  [ "$status" -eq 0 ]
  [ "$(cat "$CALLS")" = "$(printf '%s\n%s' --wait "$REPO")" ]
}

@test "a linked worktree opens that worktree rather than the main checkout" {
  git -C "$REPO" -c user.name=Test -c user.email=test@example.com commit --allow-empty -qm initial
  worktree="$BATS_TEST_TMPDIR/linked worktree"
  git -C "$REPO" worktree add -q -b smoke "$worktree"
  worktree=$(cd "$worktree" && pwd -P)
  mkdir -p "$worktree/src"
  touch "$worktree/src/file.lua"
  run bash "$SCRIPT" "$worktree/src/file.lua"
  [ "$status" -eq 0 ]
  mapfile -t args < "$CALLS"
  [ "${args[1]}" = "$worktree" ]
  [ "${args[2]}" = "$worktree/src/file.lua" ]
}

@test "repository lookup failure does not open a misleading project" {
  run bash "$SCRIPT" "$BATS_TEST_TMPDIR/outside.lua"
  [ "$status" -ne 0 ]
  [ ! -e "$CALLS" ]
}
