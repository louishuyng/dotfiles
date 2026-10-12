# Share bootstrap selection and safe config linking across platforms

Accepted on 2026-10-12. The dotfiles owner approved a shared terminal installer
for macOS, Arch, and Debian after reviewing
[the proposal](../../plans/006-bootstrap-options.md).

## Decision

Keep the existing three entry points and delegate to `bootstrap/setup.sh`.
Use Bash 3.2-compatible arrays and platform package managers. Reuse optional Gum
for keyboard selection and confirmation, with plain numbered prompts as fallback.
Show commands before application and expose explicit tasks and a read-only preview.
Use the same config-linking function for every caller, including SketchyBar's
standalone helper installer. Existing config conflicts require explicit backup
permission; correct links are repeatable and failed replacements are restored.

Match the current Neovim config's 0.12 requirement. Use the existing mise tool on
Debian for a current Neovim release rather than adding an Ubuntu PPA to Debian.
Keep SSH keys, login-shell selection, service startup, GUI permissions, and language
versions as manual steps. Preferences and security tools are opt-in tasks.

## Alternatives and trade-offs

Patching three independent scripts would retain duplicate safety and selection
code. A web UI would add a server and dependencies to machine setup. Sharing Bash
keeps one failure-handling path and a usable interface over SSH. The trade-off is
a longer task switch containing platform differences; split task definitions only
if that switch becomes difficult to follow.

The installer manages configuration links, not full machine rollback. Backups
preserve replaced configs; installed packages and opt-in preferences remain applied
after a later task fails. Existing checkouts and correct links are retained.
Personal and macOS-specific workflows remain in their source configs.

## Verification and rollback

Use `bash bootstrap/tests/setup.sh` for isolated preview, argument, platform,
backup, rerun, version, and failure checks. Verify plain selection and Gum selection
in a terminal. Live package installs and GUI behavior require a fresh-machine
check; no such installation is part of this repository change.

Restore replaced configs from the printed backup directory as described in
[the bootstrap guide](../../bootstrap/README.md#configuration-and-recovery).
Revert the repository change to restore the previous entry points. Do not execute
the old scripts as a rollback: their deletion and unconditional machine changes
are the reason for this decision.
