# Use upstream Pitago as the permanent Pi frontend

Status: accepted by explicit user request for permanent setup, not a trial.

## Decision

Install [Pitago v0.11.32](https://github.com/cavaldos/pitago/releases/tag/v0.11.32) at `~/.local/bin/pitago`. Use its upstream Go/Bubble Tea interface rather than rebuilding its logo, sidebar, pet, and input layout as native Pi widgets. Keep the real `pi` executable available: Pitago starts it with `--mode rpc`. Do not alias or replace that executable with Pitago.

The Apple Silicon release is verified against its published SHA-256 digest before execution. Store the non-secret theme and display preferences in [`terminals/pitago/`](../../terminals/pitago/README.md), with individual symlinks under a real, private `~/.config/pitago/` directory. Do not symlink the whole directory: credentials, login mirrors, recent models, and update state must remain outside the repository.

Use Gruvbox and the animated ASCII sidebar pet. Keep existing Pi provider/model defaults, credentials, extensions, and sessions. This supersedes the custom-companion visual direction in [ADR 0007](0007-pi-animated-companion.md); its native UI remains a fallback, not the Pitago renderer.

## Compatibility and trade-off

The upstream frontend supplies the desired interface without maintaining a Go fork. Its RPC transport supports ordinary Pi extension commands and supported dialogs, but native TUI component factories, custom editors, headers, and footers do not render there. Existing native widgets therefore do not define Pitago's appearance.

Pitago startup imports existing Pi API keys into its private keystore and mirrors login presence. Login/logout actions can modify Pi auth, so setup and verification do not invoke them. Self-update changes the installed version and is not part of this pinned setup. GitHub update checks may still occur at startup.

Verify the real frontend/backend path and report extension-specific limitations rather than assuming RPC parity. Keep `pi` as the native fallback for workflows requiring custom TUI surfaces. Tern/Herdr/Muxy pane control remains separate; installing Pitago does not add those integrations.
