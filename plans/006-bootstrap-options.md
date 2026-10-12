# Replace unsafe bootstrap scripts with a selectable terminal setup

Approved on 2026-10-12 for all three platforms; recorded in
[ADR 0004](../docs/adr/0004-selectable-bootstrap.md). The goal is to select setup tasks,
review their commands, and rerun setup without deleting existing configuration.

## Recommendation

Keep `bootstrap/mac.sh`, `bootstrap/arch.sh`, and `bootstrap/debian.sh` as entry
points. Share selection, preview, error reporting, and safe linking in a Bash
installer compatible with macOS's Bash 3.2. Use the already-used Gum for a keyboard
menu when available; provide numbered prompts when it is absent. Do not install a
UI dependency before the user reviews the plan.

Offer selectable groups for shell, editors, terminals, CLI tools, developer tools,
and configuration. Offer macOS desktop tools and preferences separately. Keep
alternative apps and security tools opt-in. Provide `--help`, `--list`,
`--dry-run`, explicit task selection, and a noninteractive confirmation flag.
Show selected tasks before running them and report the failed task with a retry
command. Skip existing correct links. Move conflicting files or directories to a
dated backup before replacing them, only with explicit backup permission.

Package installation uses the platform package manager. Config links use actual
repository paths; no bootstrap step creates SSH keys, changes the login shell,
disables Spotlight, changes the hostname, or starts GUI services automatically.
Explain remaining manual steps after setup. Verify current package instructions
against upstream sources before replacing obsolete commands.

## Evidence from the current scripts

| Location | Problem | Required correction |
| --- | --- | --- |
| `bootstrap/mac.sh` | `load_pre_script` changes Spotlight and runs privileged commands before selection; `default_setting_macos` always changes preferences and hostname | Remove unconditional machine changes; preferences are a separate task |
| All three scripts | Delete config files/directories; links assume `~/.dotfiles` and several sources are missing | Check sources, preserve conflicts, make linking repeatable |
| All three scripts | Run Fisher in Bash; Linux scripts install obsolete asdf versions or Neovim Packer | Use Fish for Fisher and current package manager installs |
| `bootstrap/mac.sh` | Old Homebrew installer, absent Yabai dependency, missing SbarLua, wrong tmux/Emacs paths, and several functions never called | Match current repo configs and expose supported tasks |
| `bootstrap/debian.sh` | Invalid apt invocation, obsolete Python packages, unsigned/trusted third-party apt source, and Ubuntu PPA in Debian path | Use distribution packages and avoid adding external apt repositories |

The README calls the macOS and Arch scripts. OpenCode documentation depends on
macOS bootstrap links. Existing Fish and tmux configuration contains macOS and
personal paths; the installer must disclose Linux limitations rather than claim
those configurations are portable. The checked-in Neovim config requires 0.12
features, so distro Neovim compatibility must be checked before linking it.

## Options and trade-off

Repairing each script independently keeps duplication and three separate safety
implementations. A new web UI adds a server and dependencies to a shell setup.
A shared terminal installer fixes the same failure once and works over SSH;
the trade-off is a small shared Bash file. If the platform tasks diverge enough
to obscure their commands, split only the task definitions by platform.

## Scope and validation

Implement scripts, bootstrap documentation, a decision in `docs/adr`, and a
small shell self-check. Cover argument validation, platform guards, cancellation,
dry-run without mutations, paths containing spaces, conflicts, backups, reruns,
and package-command failures using a temporary home and mocked commands.

Do not install packages or change the owner's live configuration while developing
the installer. Real installs and GUI permissions remain a separate execution
step. No containerized Linux install or fresh-machine verification is assumed.
