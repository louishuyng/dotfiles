# Set up dotfiles with a reviewed plan

Run the entry point for your platform. Select tasks, review their commands, then
confirm application. This guide is for the dotfiles owner; the configs retain
personal paths and Git identity.

```bash
bash bootstrap/mac.sh
# Other platforms:
bash bootstrap/arch.sh
bash bootstrap/debian.sh
```

Gum provides a keyboard menu with the first five tasks selected. Space toggles a
task, Enter reviews the selection, and Ctrl+C cancels. Without Gum, enter task
numbers separated by spaces. `--plain`, `NO_COLOR`, and a dumb terminal use plain
output. Install Gum through the `cli` task on macOS/Arch to enable the menu on the
next run; the installer never installs UI tools before showing the plan.

## Preview before applying

```bash
bash bootstrap/mac.sh --list
bash bootstrap/mac.sh --tasks core,git,fish,nvim,tmux,ghostty,fonts --dry-run
bash bootstrap/mac.sh --tasks core,git,fish,nvim,tmux,ghostty,fonts --backup
```

`--dry-run` prints the commands and existing config conflicts without changing
files, downloading software, or invoking package managers. You can preview any
platform from any host. Application checks the host platform and refuses root.
Tasks run once in their declared order; duplicate IDs are ignored.

| Option | Behavior |
| --- | --- |
| `--tasks ID,ID` | Choose explicit tasks; use `--list` to see platform availability |
| `--links-only` | Skip package and plugin installation; Nushell still generates its required init files from installed tools |
| `--backup` | Move conflicting configs into a private dated backup before linking |
| `--yes` | Apply explicit tasks without confirmation; backup permission remains separate |
| `--plain` | Use numbered prompts and plain text |

To link installed applications without downloading packages:

```bash
bash bootstrap/mac.sh --tasks fish,nvim,tmux,ghostty,ai --links-only --dry-run
bash bootstrap/mac.sh --tasks fish,nvim,tmux,ghostty,ai --links-only --backup
```

Full package tasks require an internet connection and may request administrator
access. Homebrew uses its [official installer](https://docs.brew.sh/Installation)
when absent. Debian updates apt metadata; Arch uses `pacman -S --needed` and
assumes an already updated system. No task performs a blanket system upgrade or
adds an unsigned apt repository. Package managers retain their own prompts even
with `--yes`.

## Configuration and recovery

The installer resolves its checkout location, then ensures `~/.dotfiles` points
there because shell and editor configs reference that path. Config destinations
honor `XDG_CONFIG_HOME` except applications with macOS-specific locations. Correct
links are skipped. Conflicting files, directories, and dangling links require
`--backup` or an interactive backup confirmation before any task runs.

Backups live under
`${XDG_STATE_HOME:-~/.local/state}/dotfiles-bootstrap/backups/<date>-<pid>/`.
The final output prints the exact directory. Each backup retains its destination
path relative to the home; destinations outside the home retain their full path
inside the backup directory. A failed link replacement restores its previous
config. Earlier successful tasks remain applied if a later command fails.

To restore a config, first verify the destination is the installer-created
symlink, unlink it, and move its saved backup back to that destination. For
example, substitute the printed backup date in these commands:

```bash
readlink ~/.config/fish
unlink ~/.config/fish
bootstrap_backup="$HOME/.local/state/dotfiles-bootstrap/backups/<date>-<pid>"
mv "$bootstrap_backup/.config/fish" ~/.config/fish
```

Package installation, preferences, and generated plugin files have separate
lifecycles; restoring a config backup does not uninstall packages or revert
preferences. The opt-in `macos` task prints every preference write in the plan.
Changes to Finder, Spaces, and keyboard preferences may require a new login.

### OMP configuration

The `ai` task links OMP configuration on all three platforms without installing
OMP. Install the binary separately, then apply the links:

```bash
bash bootstrap/mac.sh --tasks ai --links-only --dry-run
bash bootstrap/mac.sh --tasks ai --links-only --backup --yes
```

Use `arch.sh` or `debian.sh` on Linux. Existing files are backed up, not merged;
review local preferences before applying.

| Dotfiles source | Installed path |
| --- | --- |
| `ai/config/native-omp.yml` | `~/.omp/agent/config.yml` |
| `ai/config/native-omp-keybindings.yml` | `~/.omp/agent/keybindings.yml` |
| `ai/config/native-omp-mcp.json` | `~/.omp/agent/mcp.json` |
| `ai/AGENTS.md` | `~/.omp/agent/AGENTS.md` |
| `ai/skills` | `~/.omp/agent/skills` |

An existing `~/.local/share/agent-hub/skills/omp` skills link stays managed by
Agent Hub. Session auto-naming lives under `title` in `native-omp.yml`; terminal
project names remain in `terminals/sesh/sesh.toml`.

Only configuration files are linked. Sessions, databases, caches, credentials,
and other runtime state remain under OMP's local directories. Do not put tokens
or private MCP headers in tracked configuration. The extension path retains this
owner's absolute home path; change it when installing for another user.

### Tern configuration

The macOS `tern` task restores the full `terminals/tern/settings.json` snapshot,
links `terminals/tern` at Tern's `plugins/tool-keys`, and links the shared
`terminals/sesh` project-root configuration. Install Tern separately.

```bash
bash bootstrap/mac.sh --tasks tern --links-only --dry-run
bash bootstrap/mac.sh --tasks tern --links-only --backup --yes
tern plugin reload
```

The default destination is `~/Library/Application Support/Tern`;
`TERN_CONFIG_DIR` overrides it. Existing settings and conflicting plugin paths
require backup permission. Unrelated plugins remain installed.

Tern atomically replaces `settings.json` on UI saves, which breaks a file
symlink. Bootstrap therefore installs a regular copy. Before restoring over
new UI changes, capture them back into dotfiles:

```bash
bash ~/.dotfiles/terminals/tern/capture-settings.sh
```

Capture requires `jq` from the `core` task. It validates a single JSON object
before replacing the tracked snapshot. Review the full settings file for tokens
or private environment values before committing. Identical installed snapshots
are skipped on bootstrap reruns; differing preferences require a backup.

Session state, file-browser history, notes, downloaded agents, account state,
private host keys, caches, and managed OMP downloads remain local. OMP's own
configuration uses the separate `ai` task above.

## Finish selected applications

1. Open a new terminal and run `fish`. The installer leaves your login shell
   unchanged. Add Fish to `/etc/shells` and use `chsh` yourself if desired.
2. Run `gh auth login`, then `gh extension install dlvhdr/gh-dash` if the setup
   reported missing authentication. SSH keys and SSH config stay under your
   control. The `git` task links the repo's personal identity and host settings.
3. Start Neovim to let its native `vim.pack` configuration install plugins. The
   config requires Neovim 0.12+. Debian uses
   [mise](https://mise.jdx.dev/getting-started.html) to install and select
   `neovim@latest` globally because [Debian 13's package](https://packages.debian.org/trixie/neovim)
   is older. Use an activated mise shell afterward. Language versions remain
   yours to choose, for example `mise use --global node@24`.
4. In Tmux, press prefix + I to install TPM plugins. Install Doom Emacs through
   its [upstream instructions](https://github.com/doomemacs/doomemacs#install),
   then run `doom sync` for the linked `.doom.d`. Herdr is config-only; its binary
   and optional popup applications require separate installation.
5. For `desktop`, grant Aerospace accessibility permission, then start Aerospace
   and `brew services start sketchybar` yourself. The task builds
   [SbarLua](https://github.com/FelixKratz/SbarLua), installs SketchyBar's helper
   binary, Satoshi/SF fonts, and the checked-in app font. Karabiner and Docker
   need their own first-launch permissions. AI and Nix tasks link configuration;
   install those applications separately.

## Platform limits and retired commands

Debian tasks target Debian 13+ or Ubuntu 25.04+ package availability (including
Starship and git-delta). Its smaller task list avoids AUR packages and new apt
repositories. Debian `fish` omits Atuin installation; the shell skips absent
optional tools. Shell, tmux, terminal, and Git configs still contain macOS paths
or commands such as `pbcopy`; the installer does not make those workflows portable.
Linux tmux session switching requires a separately installed `sesh`.
The Home Manager flake targets this owner's Apple Silicon Mac; the `nix` task
links it on Linux but does not apply it.

The Nushell task installs its command dependencies and generates Atuin/Zoxide
init files. Its environment retains legacy asdf paths; language-manager migration
is outside this bootstrap change. Mailspring's old theme replacement, BeEF's
vendored installer, source-built Lua LSP, old Packer/asdf setup, Yabai's scripting
addition, automatic services, hostname changes, and Spotlight disabling are
retired from automatic bootstrap. Install ZAP from its
[upstream downloads](https://www.zaproxy.org/download/); its
[Homebrew cask is disabled](https://formulae.brew.sh/cask/zap).

## Verify the installer

```bash
bash bootstrap/tests/setup.sh
bats tests/tern
```

The checks isolate config and backup paths and mock package managers, downloads,
and desktop effects. They cover every platform's task previews, invalid input,
host guards, conflicts, backups, reruns, failed links, failed packages, and the
Neovim version gate. OMP coverage checks backup permission, preservation of local
settings and runtime state, Agent Hub skills links, fresh skills links, and
idempotent reruns on all three platforms. Tern coverage checks settings backups,
custom config directories, failed-copy recovery, preservation of unrelated
plugins and private state, and idempotent snapshot restores. The Tern shell suite
also checks that capture rejects invalid settings without replacing the snapshot.
A live fresh-machine install is a separate check.
