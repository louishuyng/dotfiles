Keymap for herdr. Rationale, displaced defaults, and deliberately-dropped tmux
bindings: `docs/superpowers/specs/2026-08-04-herdr-keybindings-design.md`.

Prefix is `ctrl+a`, same as tmux. Every row below is a key actually bound in
`config.toml`; keys herdr already binds natively to the same action as tmux
(`h/j/k/l`, `prefix+-`, `z`, `x`, `c`, `1..9`, `?`, `b`, `w`, `shift+x`, …) are
not written there and so are not listed here.

## Quick start

1. Help: `Ctrl+A`, then `?`; custom commands have action labels.
2. Settings: `Ctrl+A`, then `Shift+S`.
3. Projects: `Ctrl+A`, then `s`; Enter opens or focuses, Tab moves,
   Ctrl+D asks before closing the named tab, and Esc cancels.
4. Copy mode: `Ctrl+A`, then `[`; `Ctrl+A`, then `v` edits scrollback.
5. Appearance: `Ctrl+A`, then `Shift+T` toggles macOS light/dark appearance.

## Appearance and sidebar policy

Herdr follows macOS with `gruvbox` in dark mode and `gruvbox-light` in light
mode. Built-in surfaces supply the panel colors; there is no shared black
override. Ghostty uses its own light/dark palettes. Selecting a theme manually
in Herdr Settings disables automatic switching. Re-enable Follow system there
to restore this policy. Settings rewrites theme sections, including comments.
Use the client's reload-config action (`prefix+ctrl+shift+r`) when applying
client presentation changes; a server-only reload does not establish that the
client refreshed.

The sidebar baseline preserves the installed 32-column width, symbol indicators,
space ordering, machine identity, and optional summary/progress rows. Reporters
supply that metadata; this config adds no reporter. `prefix+b` collapses the
sidebar when pane space is tight. Pane-border agent labels stay disabled.

Bootstrap ownership is unchanged: the tmux component links this config. An
existing regular installed file can differ; compare and preserve its preferences
before installing. Editing this worktree does not apply these settings live.

## Project picker

Open tabs/windows appear before zoxide paths. Errors remain in the picker header;
Ctrl+R retries the list and Esc cancels. A failed lookup prevents creation.
Ctrl+D opens a confirmation with Cancel selected; only choosing Close sends a
close request. Herdr and tmux use the same controls, with tmux taking precedence
when nested inside Herdr.

Below 100 popup columns the preview starts hidden; on wider popups it occupies
45% on the right. Ctrl+P toggles it. Launcher dimensions and the separate playzone
picker stay unchanged. Verify actual Help, sidebar states, light/dark contrast,
and hosted-tool input in a disposable session before applying visual refinements.

| key | action | tmux equivalent |
|---|---|---|
| `prefix+ctrl+h` | focus previous tab | `prefix+C-h` (`previous-window`) |
| `prefix+ctrl+l` | focus next tab | `prefix+C-l` (`next-window`) |
| `prefix+d` | detach | `prefix+d` (`detach-client`) |
| `prefix+ctrl+c` | new workspace | `prefix+C-c` (`new-session`) |
| `prefix+,` | rename tab | `prefix+,` (stock tmux `rename-window`; this repo's tmux.conf rebinds `,`/`.` to swap-window instead) |
| `prefix+$` | rename workspace | `prefix+$` (`rename-session`) |
| `prefix+v` | edit scrollback in nvim | `prefix+v` then `y` (copy-mode, then yank) |
| `prefix+[` | copy mode | `prefix+[` (stock tmux `copy-mode`; herdr ships this action unbound) |
| `prefix+<` | move tab left | `prefix+,` (`swap-window -t -1`) |
| `prefix+>` | move tab right | `prefix+.` (`swap-window -t +1`) |
| `prefix+tab` | focus last pane | `prefix+Tab` (`last-window` — herdr has no last-tab action) |
| `prefix+shift+s` | herdr settings | none — displaced by the project picker on `prefix+s` |
| `prefix+ctrl+g` | herdr goto | none — displaced by gh dash on `prefix+g` |
| `prefix+ctrl+shift+r` | reload herdr config | `prefix+r` (`source-file` reload; rare, also reachable via `herdr server reload-config`) |
| `prefix+shift+1..9` | switch workspace by number | none — new |
| `prefix+ctrl+k` | focus previous workspace | none — new |
| `prefix+ctrl+j` | focus next workspace | none — new |
| `prefix+/` | popup: yazi | `prefix+/` (`display-popup` yazi) |
| `prefix+i` | popup: lazydocker | `prefix+i` |
| `prefix+t` | popup: tuxedo | `prefix+t` |
| `prefix+shift+r` | popup: serpl | `prefix+R` (`display-popup` serpl) |
| `prefix+a` | Herdr Projects: open the work board | none |
| `prefix+ctrl+r` | popup: tuicr | `prefix+C-r` |
| `prefix+g` | popup: gh dash | `prefix+g` (full tmux window; popup in herdr) |
| `prefix+n` | popup: note.sh | `prefix+n` (full tmux window; popup in herdr) |
| `prefix+p` | popup: playzone picker | `prefix+p` (`display-popup` playzone) |
| `prefix+s` | popup: project picker | `prefix+s` (`display-popup` sesh) |
| `prefix+left` | swap pane left | `prefix+Left` (falls back to prev/next pane at an edge; herdr no-ops instead) |
| `prefix+down` | swap pane down | `prefix+Down` |
| `prefix+up` | swap pane up | `prefix+Up` |
| `prefix+right` | swap pane right | `prefix+Right` |
| `prefix+shift+t` | toggle macOS appearance | `prefix+T` (tmux-local theme script) |
| `prefix+minus` | split below, new pane at 30% | `prefix+-` (`split-window -v -l 30%`) |
| `` prefix+\| `` | split right, 50/50 | `` prefix+\| `` (`split-window -h -l 50%`) |
| `prefix+H` | resize left | `prefix+H` (`resize-pane -L 3`) |
| `prefix+J` | resize down | `prefix+J` (`resize-pane -D 3`) |
| `prefix+K` | resize up | `prefix+K` (`resize-pane -U 3`) |
| `prefix+L` | resize right | `prefix+L` (`resize-pane -R 2`) |
| `prefix+{` | swap pane with previous | `prefix+{` (`swap-pane -U`) |
| `prefix+}` | swap pane with next | `prefix+}` (`swap-pane -D`) |
