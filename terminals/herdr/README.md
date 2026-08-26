Keymap for herdr. Rationale, displaced defaults, and deliberately-dropped tmux
bindings: `docs/superpowers/specs/2026-08-04-herdr-keybindings-design.md`.

Prefix is `ctrl+a`, same as tmux. Every row below is a key actually bound in
`config.toml`; keys herdr already binds natively to the same action as tmux
(`h/j/k/l`, `prefix+-`, `z`, `x`, `c`, `1..9`, `?`, `b`, `w`, `shift+x`, …) are
not written there and so are not listed here.

Theme (`[theme]` / `[theme.custom]`) is `nord` with `panel_bg = "#2e3440"`, which
is what separates herdr's chrome from the host terminal's background — pane
interiors are ghostty's `background`, which herdr reads via OSC 11. herdr's
settings UI rewrites both sections wholesale, so a theme change made there wins
until the file is restored and `herdr server reload-config` is run. Editing
`config.toml` alone is not enough: the running server keeps its in-memory theme
and will write it back over the file.

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
| `prefix+a` | popup: posting | `prefix+a` |
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
