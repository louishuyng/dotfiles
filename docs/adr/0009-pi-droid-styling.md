# Use pi-droid-styling with native Pi

Status: accepted by user approval. Supersedes [ADR 0008](0008-pitago-frontend.md).

## Context

Pitago replaces Pi's terminal interface through RPC, so native editors, footers, and widgets cannot define its appearance. The user requested the upstream [pi-droid-styling](https://github.com/sting8k/pi-droid-styling) interface instead and removal of Pitago and its Fish alias.

## Decision

Use native Pi with `npm:@sting8k/pi-droid-styling@3.0.0`, pinned in the user settings and shared package manifest. Keep the existing provider, model, `wired-theater` theme, and Pip companion. Disable the installed Powerline package's extensions so only Droid controls the footer. Keep its old configuration available for rollback.

Remove the `pi="pitago"` Fish alias. Move the Pitago binary and private configuration to `~/.local/state/pi-ui-backups/20261026-145821/` rather than deleting credentials. Preserve repository Pitago files as archived reference. Do not change Pi authentication or sessions.

## Consequences

The requested styling runs in Pi's own terminal UI, and native widgets remain available. A separate RPC frontend is no longer needed. The styling extension requires Pi 1.x and patches rendering internals; upstream Pi upgrades need startup, reload, resize, and keyboard checks. The package bundles its theme collection, but the selected local theme remains unchanged.

The installer reconciles Pi's shared npm dependency tree and reported 20 vulnerabilities. No automatic audit fixes or unrelated dependency upgrades were requested separately. This setup does not claim those dependencies are vulnerability-free.
