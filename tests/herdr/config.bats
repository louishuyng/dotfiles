#!/usr/bin/env bats
# herdr disables invalid keybindings with only a warning, so "no warnings" is
# the real gate — `config: ok` alone would pass with every binding dead.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  XDG="$BATS_TEST_TMPDIR/xdg"
  mkdir -p "$XDG/herdr"
  cp "$REPO/terminals/herdr/config.toml" "$XDG/herdr/config.toml"
}

@test "config validates with no disabled bindings" {
  run env XDG_CONFIG_HOME="$XDG" herdr config check
  [ "$status" -eq 0 ]
  [[ "$output" == *"config: ok"* ]]
  [[ "$output" != *"invalid keybinding"* ]]
}

@test "prefix is ctrl+a" {
  grep -q '^prefix = "ctrl+a"$' "$XDG/herdr/config.toml"
}

@test "theme follows host appearance with the chosen variants" {
  grep -q '^auto_switch = true$' "$XDG/herdr/config.toml"
  # herdr's settings UI writes this file, so pin the variants too — a UI-driven
  # theme change should surface here deliberately, not as a mystery red.
  grep -q '^dark_name = "rose-pine"$' "$XDG/herdr/config.toml"
  grep -q '^light_name = "rose-pine-dawn"$' "$XDG/herdr/config.toml"
  # `name` must stay absent: with auto_switch on it is redundant, and its
  # presence means the UI overwrote our config again.
  ! grep -q '^name = ' "$XDG/herdr/config.toml"
}

@test "cycle_pane_next is cleared so last_pane can own prefix+tab" {
  grep -q '^cycle_pane_next = ""$' "$XDG/herdr/config.toml"
  grep -q '^last_pane = "prefix+tab"$' "$XDG/herdr/config.toml"
}

@test "keys scalars that the command-records test cannot see are pinned" {
  # The table-driven test below only parses [[keys.command]] blocks, so plain
  # [keys] scalars need their own assertions or they can vanish silently.
  grep -q '^previous_workspace = "prefix+ctrl+k"$' "$XDG/herdr/config.toml"
  grep -q '^next_workspace = "prefix+ctrl+j"$' "$XDG/herdr/config.toml"
  grep -q '^split_horizontal = ""$' "$XDG/herdr/config.toml"
  grep -q '^split_vertical = ""$' "$XDG/herdr/config.toml"
}

# One "key|type|command|width|height" record per [[keys.command]] block, so a
# wrong size, command or type fails instead of slipping past a key-only grep.
cmd_records() {
  awk '
    function val(s) { if (match(s, /"[^"]*"/)) return substr(s, RSTART+1, RLENGTH-2); return "" }
    /^\[\[keys\.command\]\]/ { if (k != "") print k "|" t "|" c "|" w "|" h; k=t=c=w=h=""; next }
    /^key *=/     { k = val($0); next }
    /^type *=/    { t = val($0); next }
    /^command *=/ { c = val($0); next }
    /^width *=/   { w = val($0); next }
    /^height *=/  { h = val($0); next }
    END { if (k != "") print k "|" t "|" c "|" w "|" h }
  ' "$1"
}

@test "every command binding has the exact key, type, command and size" {
  cmd_records "$XDG/herdr/config.toml" > "$BATS_TEST_TMPDIR/cmds"

  while IFS= read -r want; do
    [ -z "$want" ] && continue
    grep -qxF "$want" "$BATS_TEST_TMPDIR/cmds" || {
      echo "missing or wrong: $want"
      echo "--- actual records ---"
      cat "$BATS_TEST_TMPDIR/cmds"
      return 1
    }
  done <<'WANT'
prefix+/|popup|yazi|80%|80%
prefix+i|popup|lazydocker|80%|80%
prefix+t|popup|tuxedo|80%|80%
prefix+shift+r|popup|serpl|80%|80%
prefix+a|popup|posting|90%|90%
prefix+ctrl+r|popup|tuicr|90%|90%
prefix+g|popup|gh dash|90%|90%
prefix+n|popup|~/.dotfiles/terminals/notes/note.sh|90%|90%
prefix+p|popup|~/.dotfiles/terminals/playzones/playzone-picker.sh|80%|80%
prefix+s|popup|~/.dotfiles/terminals/sesh/sesh-picker.sh|80%|80%
prefix+left|shell|herdr pane swap --current --direction left||
prefix+down|shell|herdr pane swap --current --direction down||
prefix+up|shell|herdr pane swap --current --direction up||
prefix+right|shell|herdr pane swap --current --direction right||
prefix+shift+t|shell|~/.dotfiles/terminals/herdr/scripts/toggle-appearance.sh||
prefix+minus|shell|herdr pane split --current --direction down --ratio 0.70 --focus||
prefix+||shell|herdr pane split --current --direction right --ratio 0.50 --focus||
prefix+H|shell|herdr pane resize --current --direction left --amount 0.05||
prefix+J|shell|herdr pane resize --current --direction down --amount 0.05||
prefix+K|shell|herdr pane resize --current --direction up --amount 0.05||
prefix+L|shell|herdr pane resize --current --direction right --amount 0.05||
prefix+{|shell|~/.dotfiles/terminals/herdr/scripts/pane-swap.sh prev||
prefix+}|shell|~/.dotfiles/terminals/herdr/scripts/pane-swap.sh next||
WANT

  # Exact count: catches a stray or duplicated block the table alone would miss.
  [ "$(wc -l < "$BATS_TEST_TMPDIR/cmds")" -eq 23 ]
}

@test "herdr's panel background is pinned distinct from Ghostty's" {
  # Ghostty's dark background is #11111B; this must not drift back to matching
  # it, and `reset` would make herdr inherit the terminal background again.
  grep -q '^panel_bg = "#26233a"$' "$XDG/herdr/config.toml"
}

@test "the appearance toggle flips macOS appearance without writing config" {
  grep -qF 'toggle-appearance.sh' "$XDG/herdr/config.toml"

  local s="$REPO/terminals/herdr/scripts/toggle-appearance.sh"
  [ -x "$s" ]
  grep -q 'osascript' "$s"

  # Writing config.toml here would dirty the git-tracked symlink target on
  # every single toggle — that is why the toggle flips host appearance instead.
  ! grep -q 'config\.toml' "$s"
  ! grep -qE '>>|[^0-9<>]>[^&]|sed -i|tee ' "$s"
}
