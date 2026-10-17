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

## Tern

The [Tern plugin](../tern/window.luau) adds Herdr-style `Ctrl+A` shortcuts while
keeping Tern's native shortcuts and installed preferences. Link or restore it:

```bash
tern plugin link ~/.dotfiles/terminals/tern
tern plugin list --json
```

The plugin needs `plugin.toml`, `window.luau`, and `projects.sh` in
`terminals/tern`. Keep these files in version control alongside `settings.json`
and `zed-project.sh`; the installed `.path` link alone cannot restore missing
files. After edits, use `tern plugin reload`. A healthy plugin list reports
`herdr-keys` as ready with no problems.

### Project spaces

`Ctrl+A`, then `s` opens the project picker. Named roots come from
`~/.config/sesh/sesh.toml` (`SESH_TOML` overrides it); other directories come
from zoxide. The first matching root supplies the session name, just as in
Herdr. `regask/alert` opens an `alert` tab inside **RegAsk**, and
`regask/company` opens a sibling tab in the same session. Selecting a project
again focuses its existing pane. Outside configured roots, the directory's
basename supplies the session name.

The `dotfiles` choice always opens `~/.dotfiles` under its configured root
session (`LX-CONFIG`). History entries named `dotfiles` or `.dotfiles` collapse
into that canonical choice instead of opening a worktree. Existing sessions
with those names do not override it; use `Ctrl+A w` to select such a session
explicitly.

For histories longer than Tern 0.9.2's 200-item picker limit, choose **Search
all projects…**, enter words from the name or path, then select the result.
Remote hosts list their existing spaces only; local paths are not sent there.

### Keys

Press `Ctrl+A`, then the key below.

| Key | Action |
| --- | --- |
| `\` / `-` | Split right / below, both 50/50 |
| `s` / `w` | Project picker / session switcher |
| `Ctrl+C` / `$` | New / rename session |
| `Ctrl+K` / `Ctrl+J` / `Shift+1` … `Shift+9` | Previous / next / numbered session |
| `c` / `,` / `Shift+X` | New / rename / close tab |
| `Ctrl+H` / `Ctrl+L` / `1` … `9` | Previous / next / numbered tab |
| `<` / `>` | Move tab left / right |
| `h j k l` / `Tab` / `Shift+Tab` | Directional focus / last pane / previous pane |
| `H J K L` / arrows / `{` / `}` | Resize / directional swap / previous swap / next swap |
| `z` / `x` / `b` | Zoom / close pane / toggle sidebar |
| `?` / `o` / `v` | Command palette / inbox / scrollback in editor |
| `Shift+S` / `Ctrl+G` / `Ctrl+Shift+R` | Settings / directory picker / reload settings |
| `/` / `i` / `t` | Yazi / Lazydocker / Tuxedo |
| `Shift+R` / `Ctrl+R` / `n` / `p` | Serpl / Tuicr / notes / playzones |
| `Shift+T` / `Ctrl+A` | Toggle macOS appearance / send Ctrl+A to the program |

`terminals/tern/settings.json` overrides `Ctrl+A g` with Tern's native Git
block and selects the Zed project opener. Installed theme and other preferences
are separate; linking the plugin does not replace them. Custom settings and
presets take precedence over plugin bindings.

Inside omp, plain `Ctrl+N` (without `Ctrl+A`) opens Neovim in a right split
using omp's current project directory. If this tab already has a running
Neovim, it focuses that pane instead. The shared `ai/hooks/omp-extension.ts`
uses the same `scripts/nvim-tab.sh` launcher as Fish and Zsh. Restart existing
omp processes after changing the extension. Other terminals keep their normal
`Ctrl+N` behavior.

Plain `Ctrl+G` in omp opens the active session's repository root in Zed, or its
current directory when it is not inside a repository. Zed maps that root to its
own saved project and restores that project's layout and tabs, even if another
project is focused. No `--new`, `--reuse`, temporary draft path, or stdin buffer
is sent; the unsent omp draft stays in omp. For this repository, the mapping is
`~/.dotfiles` → Zed's `.dotfiles` project.

The extension needs the native temporary-file shortcut disabled. When
`~/.omp/agent/keybindings.yml` does not exist, link its repository-owned source:

```bash
ln -s ~/.dotfiles/ai/config/native-omp-keybindings.yml ~/.omp/agent/keybindings.yml
```

If that file already contains custom bindings, preserve them and merge
`app.editor.external: []` instead. Restart omp after changing the extension or
keybindings. This changes omp's `Ctrl+G`, not the editor used by Git or Tern.

Unlike Herdr, Tern launchers use tabs instead of popups. `|` is not the right
split key. Herdr-only copy mode (`[`), detach (`d`), modal resize (`r`), and
Herdr Projects (`a`) remain unbound rather than running unrelated actions.
