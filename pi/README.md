# Pi interface

Run **`pi`** for the native terminal interface with [`pi-droid-styling` 3.0.0](https://github.com/sting8k/pi-droid-styling): a boxed editor, compact model/context rows, styled conversations, and tool output. Pi 1.x is required. The bundled green `qoder-cli` theme, `reasonix` conversations, Gemini-style status rows, and balanced half-block input padding follow the upstream screenshot. Startup is visible (`quietStartup: false`). The local `agent/extensions/droid_header.ts` restores the original large gradient logo through Pi's native header API; it retains the upstream MIT license. The old **Pip / Wired Companion** panel is disabled in the user settings and shared extension manifest.

The display settings live in `agent/settings.json` and `agent/pi-droid-styling.json`. The Powerline package remains installed with its extensions disabled to avoid competing footers. The package declarations in `agent/settings.json` and [`native-pi-packages.json`](../ai/config/native-pi-packages.json) include the pinned styling extension. Install it on a new machine with:

```sh
pi install npm:@sting8k/pi-droid-styling@3.0.0
```

The Fish `pi="pitago"` alias is removed. Existing shells must run `functions -e pi` once, or start a new Fish shell. Pitago's binary and private config were moved to `~/.local/state/pi-ui-backups/20261026-145821/`; credentials and sessions were not deleted. Its repository configuration is retained as historical reference, not an active frontend. See [ADR 0009](../docs/adr/0009-pi-droid-styling.md).

## Archived companion (disabled)

`agent/extensions/companion.ts` is retained but excluded from automatic loading. Its controls below apply only if explicitly re-enabled; normal Pi startup and `/reload` do not show the panel.

| Command | Effect |
| --- | --- |
| `/companion pause` | Stop motion; keep live state labels. |
| `/companion resume` | Restore animation. |
| `/companion hide` | Remove Pip and stop its timers. |
| `/companion show` | Restore Pip, retaining the paused/running preference. |

Start without companion motion:

```sh
pi --companion-static
```

`resume` can enable motion even after starting with the static flag. Command preferences are session-local: `/reload`, `/new`, and session replacement reset visibility and restore the startup flag's motion preference.

The native companion blinks about every six seconds at idle and animates its moon-like face and particle field every 400 ms while working. It waits during blocking Pi UI prompts and reacts when the agent finally settles. It does not infer approval from a closed prompt. Errors and cancellation do not trigger a completion celebration.

Below 40 terminal columns, Pip becomes a single status line. It never captures keyboard input or replaces the editor, footer, or review UI. RPC, JSON, and print modes create no companion UI or timers.

Pip works independently of Tern, Herdr, and Muxy. It does not add terminal notifications or enable their currently excluded integrations. The terminal application's font, padding, and background remain unchanged.

## Checks

With Node.js and Pi installed on `PATH`, run from the repository root:

```sh
node --test tests/pi/droid_header.test.mjs tests/pi/companion.test.mjs
```

The tests use the installed Pi loader and terminal-width helpers without calling a model. Header checks cover narrow/wide layouts, truecolor/256-color gradients, theme changes, shutdown, and non-TUI modes; archived companion tests advance deterministic timers. Check the actual interface in Pi after `/reload`: confirm the companion panel is absent, resize the terminal, type a multiline draft, and confirm settings navigation remains usable.

See [the header decision](../docs/adr/0010-pi-screenshot-header.md) for the maintained screenshot adaptation. The [companion decision](../docs/adr/0007-pi-animated-companion.md) describes the disabled legacy panel.
