# Pitago

> Archived setup: native `pi` with `pi-droid-styling` replaces this frontend. The binary and private config were backed up outside the repository; the Fish alias is removed. See [the current Pi setup](../../pi/README.md). The instructions below describe the previous installation.

Run `pitago` for the permanent Pi frontend: large logo, animated ASCII pet, session sidebar, and Gruvbox colors. Run `pitago -c` to resume the most recent Pi session. The real `pi` command remains its backend and the native fallback; do not replace it with a Pitago executable or wrapper.

## Installed version

- Release: [v0.11.32](https://github.com/cavaldos/pitago/releases/tag/v0.11.32)
- Binary: `~/.local/bin/pitago` (already on this machine's `PATH`)
- Asset: `pitago-v0.11.32-darwin-arm64`
- SHA-256: `295797e0b06497cf7eb6a568e37ea4bfc0e064546b4ebb0e8278200d5cd9ac11`

The release digest was verified before installation. The binary is installed locally, not committed.

For a fresh Apple Silicon installation, download this pinned asset, verify it, and install without overwriting another binary:

```sh
curl -fL https://github.com/cavaldos/pitago/releases/download/v0.11.32/pitago-v0.11.32-darwin-arm64 -o /tmp/pitago-v0.11.32-darwin-arm64 &&
printf '%s  %s\n' '295797e0b06497cf7eb6a568e37ea4bfc0e064546b4ebb0e8278200d5cd9ac11' /tmp/pitago-v0.11.32-darwin-arm64 | shasum -a 256 -c - &&
mkdir -p "$HOME/.local/bin" &&
test ! -e "$HOME/.local/bin/pitago" && test ! -L "$HOME/.local/bin/pitago" &&
install -m 755 /tmp/pitago-v0.11.32-darwin-arm64 "$HOME/.local/bin/pitago"
```

Do not run the install command unless verification reports `OK`. `/update` and `pitago --update` replace it with a newer upstream version; they are not part of this pinned setup.

## Configuration

Only these files are linked into `~/.config/pitago/`:

| Repository file | Purpose |
| --- | --- |
| `theme.json` | Gruvbox palette. |
| `prefs.json` | Animated pet and display preferences; Pitago saves later UI choices here. |

The config directory itself is **not** linked. Pitago's `keys.json`, `pi_auth.json`, recent models, and update cache stay local and must never be committed. Pitago imports existing Pi API keys at startup into its private keystore; `/login` and `/logout` can change Pi's auth. No login/logout is needed to reuse the existing backend.

To restore the UI links on another machine after installing Pitago, run the following only when the destination files do not already exist. Back up existing preferences first; do not overwrite them.

```sh
mkdir -p "$HOME/.config/pitago"
chmod 700 "$HOME/.config/pitago"
ln -s "$HOME/.dotfiles/terminals/pitago/theme.json" "$HOME/.config/pitago/theme.json"
ln -s "$HOME/.dotfiles/terminals/pitago/prefs.json" "$HOME/.config/pitago/prefs.json"
```

## Controls

| Action | Control |
| --- | --- |
| Show/hide the sidebar | `Ctrl+E` or `/sidebar` |
| Change pet or palette | `/pet` or `/theme` |
| Pick a model / recent model | `/model` / `Ctrl+R` |
| Native terminal selection | `/mouse off` |
| Reload Pi extensions / quit | `/reload` / `/quit` |

Native Pi TUI widgets such as Powerline and the local companion do not render over RPC. Extension commands and supported select/confirm/input/editor dialogs use the backend protocol; do not assume custom overlays work. Use `pi` for native-only workflows. Terminal fonts, padding, wallpaper, and transparency are unchanged.

## Verification and known limits

Verified locally with the real installed Pitago and Pi backend: sidebar/pet startup, model/pet/theme pickers, extension reload, a no-model subagent `/run` usage response, draft input/cancel, resize from 150 to 80 columns, and `/quit` returning 0. Backend state and Plannotator/subagent command discovery also pass. Pi auth/settings hashes remain unchanged; credential files stay private outside the repository.

Pitago v0.11.32 closes the backend output pipe during exit; with this Pi version the backend can log `write EPIPE` in `/tmp/pitago-pi-stderr.log` after `/quit`. It was absent while running, and the frontend exited 0. This is an upstream shutdown diagnostic, not a verified loss of session data.

The native `/agents` manager and chain-clarification screens use `ctx.ui.custom()`, which RPC does not support. Use native `pi` for those custom overlays. Plannotator commands are discoverable, but actual browser review/Ask AI and real subagent/model runs were not exercised. No provider tokens were spent during setup. Actual Tern contrast and mouse-selection behavior still need a visual/manual pass.

See [ADR 0008](../../docs/adr/0008-pitago-frontend.md) and [upstream configuration documentation](https://github.com/cavaldos/pitago/blob/v0.11.32/resources/doc/CONFIGURATION.md).
