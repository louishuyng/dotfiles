# Pi interface redesign — Pip animated companion

## Current direction — permanent Pitago setup approved

The user now prefers [Pitago](https://github.com/cavaldos/pitago), superseding the Navi-style visual work. Stop companion restyling until this decision is confirmed. The latest local Navi-style changes (five-row moon/particle panel below the editor and the `wired-theater` theme) pass 10 focused tests and TypeScript checking, but have not had their new rendered path verified and are not a final delivered design.

Inspected Pitago's README, main screenshot, architecture/configuration documentation, and subagent-surface-host documentation. Pitago is a separate Go/Bubble Tea frontend that launches `pi --mode rpc`, not a native Pi theme or widget. Its screenshot includes a large wordmark, right sidebar with a pet and session/model/context/workspace information, and a bordered input area. The screenshot's wallpaper/transparency belongs to the terminal and remains outside this Pi-only task.

The user explicitly approved permanent setup, not a trial. Install upstream Pitago v0.11.32 for darwin-arm64 into `~/.local/bin/pitago`, verifying the GitHub asset digest `295797e0b06497cf7eb6a568e37ea4bfc0e064546b4ebb0e8278200d5cd9ac11` before execution. Keep `pi` as the real backend executable; do not alias it to Pitago and risk subprocess recursion. Track only non-secret theme/display preferences under `terminals/pitago/`, symlink those individual files into a private real `~/.config/pitago/` directory, and leave credentials/runtime state there. Preserve native Pi settings/auth files and existing unrelated edits. Verify the actual UI and extension compatibility; do not invoke login/logout or self-update.

Trade-off: the actual frontend provides the requested sidebar/pet/layout without maintaining a custom Go fork, but native TUI widgets such as Powerline and the local companion do not render over RPC. Commands/hooks may still run server-side; Plannotator, subagent interactions, and terminal integration need explicit end-to-end checks. Keep native Pi as the fallback. Permanent installation/configuration permission is confirmed. Native Pi is retained as the backend and fallback, not replaced or uninstalled.

## Permanent Pitago verification

Installed `~/.local/bin/pitago` reports v0.11.32; the Apple Silicon release digest matches the pinned GitHub asset. `~/.config/pitago/` is a real 0700 directory; only `theme.json` and `prefs.json` link to `terminals/pitago/`. Credential files remain regular local 0600 files. Git ignores runtime/credential files under the repository's Pitago config folder as an additional safeguard.

The real frontend passes startup with existing `openai-codex/gpt-6.1-sol`, animated sidebar pet, model/pet/theme pickers, extension reload, `/run` usage response without model work, draft input/cancel, resize 150→80 columns, and `/quit` exit 0. Captured in `/tmp/pitago-setup-pty.log`; temporary harness `/tmp/pitago-pty-check.py`. Direct real RPC get_state/get_commands confirms subagent and Plannotator commands. Native Pi auth/settings hashes remain unchanged from the pre-installation baseline.

Known upstream issue: `write EPIPE` can appear in the Pi backend log only after quitting; it was absent while running and the frontend exits 0. Documented, not suppressed. Custom native `/agents` and chain-clarification overlays require native Pi because RPC `custom()` is unsupported. Plannotator browser review/Ask AI, actual provider/subagent runs, and actual Tern contrast/mouse selection remain unverified. No model calls or login/logout actions were performed.

Permanent setup and decision documentation: `terminals/pitago/README.md`, `pi/README.md`, and `docs/adr/0008-pitago-frontend.md`. The native companion design is superseded as the primary interface and retained only as the native fallback. No `pi` alias, credential changes, default-provider/model changes, commit, or PR were made.

## Context

Audience: the owner of this dotfiles repository. Goal: add a distinctive animated companion to Pi without changing terminal settings or coding workflows.

Confirmed scope: Pi's interface only. The original minimal footer is implemented and checked; the user now prefers the animated-companion showcase over the proposed neon cockpit. This revision proposes Pip, a small original pixel bird inspired by Navi's presence near the editor. The companion revision was approved in Plannotator (`decision: approved`) and explicitly approved in this conversation. Pip is implemented locally; no commit or PR has been created.

Current findings:
- `pi/agent/settings.json` selects `catppuccin-mocha`.
- Installed packages include `@ifi/oh-pi-themes` and `pi-powerline-footer`; prefer their existing customization capabilities before adding UI code.
- Local extensions are `herdr-agent-state.ts` and `muxy-notify.ts`, both excluded in settings. The shared hook loads from `ai/hooks/pi-extension.ts`.
- Pi supports role-based JSON themes. Layout changes require investigating extension APIs rather than assuming themes can change layout.
- The working tree contains existing unrelated changes, including `pi/agent/settings.json`. Preserve these changes.
- `~/.pi/agent/settings.json` resolves to this repository's `pi/agent/settings.json`.
- The installed footer supports `minimal`, plain separators, custom segment layouts, `welcome: false`, percentage-only context, and agent-directory color overrides. No new UI extension is necessary.
- Its minimal preset uses very dim clean-git/context colors and omits queue/status segments; the implemented overrides preserve readability and operational feedback.
- Upstream Navi imports the older `@mariozechner` namespace and combines its companion with feed requests, music globals, persistence, and multiple animation timers. Use it as visual inspiration, not as a drop-in dependency.
- Installed Pi supports a keyed `setWidget` component factory with `dispose`, injected theme/TUI, width-aware rendering, and `requestRender`. Its widget-placement example verifies the editor-adjacent placement API.
- `agent_settled`, not `agent_end`, signals final idle; `ui_prompt_start/end` identify actual blocking prompts. Session shutdown also occurs during reload/replacement, so timer cleanup must be idempotent.

## Approach

Keep the working minimal footer and Catppuccin Mocha. Add one presentation-only local extension, using Pi's native widget factory rather than replacing the editor, footer, or terminal renderer. Do not install pi-workstation.

Recommended design:
- **Pip:** an original three-row pixel bird vignette with a small `PIP / pi companion` wordmark, restrained orbit/spark details, and readable status text. Use the active theme's accent/text/success/warning/error roles; no hardcoded ANSI palette, emoji, or external image requirement.
- **Placement:** one keyed widget above the editor, leaving Powerline below it and review/queue indicators untouched. Keep the same widget height through ordinary mood changes. Below 40 columns, collapse to a single-line bird/status rather than crowding input; truncate with Pi's terminal-width helpers. Never handle input or steal focus.
- **Motion:** gentle blink about every six seconds while idle; cycle working frames no faster than every 400 ms. Keep the bird in a fixed area, with no flashing, scrolling text, or full-width particles. Show a brief completion expression, then return to idle. Request rendering only when the frame or state changes.
- **State:** ready at idle, working on `agent_start`, waiting while a blocking UI prompt is open, and stopped/finished on final `agent_settled` based on its `aborted` flag. Track active tool-call IDs if showing a tools expression because calls can overlap. A final assistant error must not produce a success celebration. Do not label intermediate `agent_end` events as completion or infer review approval from UI closure. On reload, derive initial busy/idle state from the fresh context.
- **Controls:** `/companion pause`, `/companion resume`, `/companion hide`, and `/companion show` are session controls. Pausing keeps state labels but removes animation timers. Hiding removes the widget and its timers. A `--companion-static` extension flag disables motion from startup for reduced-motion use; terminal UIs have no CSS media query. Document controls, startup flag, and reset-on-reload behavior.

Initialize rendering/timers only when `ctx.mode === 'tui'`. Release timers and UI references both on widget disposal and `session_shutdown`; no module/factory-time resources. Non-interactive modes must emit no companion output and start no timers.

Trade-off: one small extension gives a unique mascot without the feeds, music, token-based leveling, persistence, and older APIs bundled with Navi. This is visual presence, not an autonomous agent, notification bridge, or new workflow.

Out of scope: terminal emulator configuration, provider/model defaults, shared hooks, keybindings, queue semantics, other editors, package installs, and changes under `node_modules`. Tern/Herdr/Muxy IPC integration remains separate; the companion works independently of terminal brand.

## Files to modify

- `pi/agent/extensions/companion.ts` (new): native widget, original bird frames, event-driven moods, timer lifecycle, commands, and static flag. Auto-discovery loads this direct extension file; no package or settings change is needed.
- `tests/pi/companion.test.mjs` (new): focused loader/mock-UI/fake-timer tests of the actual extension.
- `pi/README.md` (new): concise user controls, reduced-motion startup, and check instructions.
- `.gitignore`: allow this README through the existing `pi/*` runtime-data exclusion so the documentation is not silently omitted.
- `docs/adr/0007-pi-animated-companion.md` (new): record why a local native widget is used instead of installing Navi's full bundle.
- `plans/pi-terminal-redesign.md`: retain this revised scope and verification record.

Preserve the already implemented `pi/agent/settings.json` and `pi/agent/extensions/powerline-footer/theme.json` changes; do not overwrite unrelated edits.

## Reuse

- `pi/agent/settings.json`: current resource and package configuration.
- Installed `@ifi/oh-pi-themes`: existing palette source.
- Installed `pi-powerline-footer/presets.ts`: minimal preset, basename path, conditional shell mode.
- Installed `pi-powerline-footer/powerline-config.ts`: verified parser and layout merging for the proposed options.
- Installed `pi-powerline-footer/theme.ts`: verified agent-dir override lookup and override precedence. These files are read-only dependencies under `~/.pi/agent/npm/node_modules/`.
- Installed Pi docs `extensions.md`, `tui.md`, `configuration.md`, and `themes.md`: session-scoped resources, terminal-only mode guards, semantic themes, and extension auto-discovery.
- Installed `examples/extensions/widget-placement.ts` and `dist/core/extensions/types.d.ts`: verified widget placement/factory/disposal and agent/UI-prompt event signatures.
- Installed `@earendil-works/pi-tui` width helpers and injected `tui.requestRender`: reuse native rendering and resize handling.
- Existing temporary verification harness `/tmp/pi-minimal-check.mjs`: installed Pi's Jiti loader with its TUI alias; adapt this loading approach for the focused test without installing dependencies.

## Steps

- [x] Approve this revised companion design in Plannotator before adding executable code.
- [x] Implement Pip's native widget, state transitions, animation controls, and cleanup.
- [x] Add focused lifecycle/rendering tests and document controls plus the architecture decision.
- [x] Exercise the real Pi widget, reload/resizing/keyboard interactions, static mode, and footer coexistence; record evidence and blocked checks.
- [x] Inspect the task-only diff and deliver the companion with one concrete try-it action.

## Verification

- Load the real extension using installed Pi's Jiti loader and a mocked ExtensionAPI/UI. Use deterministic fake timers to check idle/working/waiting/completion/aborted/error states, overlapping prompts/tools, repeated start events, and final settlement versus intermediate agent-end events.
- Assert pause/static/hide start no animation timers; resume/show recreate at most one active animation timer. Test repeated shutdown/dispose and reload replacement so no old callbacks update a new session. Print/JSON/RPC modes must register no widget and create no timers.
- Render at 20/39/40/60/80/120 columns with actual terminal-width helpers. Verify all lines fit, ordinary moods retain height, compact mode remains usable, theme changes use fresh styling, and labels convey states without color alone.
- Run fresh Pi PTY sessions with the real extension at 60/80/120 columns; inspect frame changes, `/companion` controls, `/reload`, and resize. Use deterministic injected lifecycle events in an isolated verification session to exercise working/waiting/completion without spending provider tokens or installing tools.
- Exercise draft input, multiline entry, cancellation, keyboard commands, and selection while the mascot animates. Confirm Powerline and review prompts remain usable. Capture terminal evidence; distinguish ANSI/PTTY observation from an actual Tern screenshot/contrast check.
- Verify the static flag from startup and measure that idle redraws remain sparse. Preserve the passing minimal-footer checks unless a relevant change invalidates them. Run task-focused syntax/diff checks.
- If actual Tern rendering/contrast, selection, or streaming checks cannot be performed, report those specific limitations and request a manual screenshot pass. Terminal UI only: web checklist rules do not apply.

## Implementation evidence and revised direction

Pip implementation:
- `node --test tests/pi/companion.test.mjs`: 9 tests pass against the real extension loaded with Pi's installed Jiti/TUI. Covers deterministic animation timing, moods, overlap, commands, disposal/replacement/shutdown, static/non-TUI modes, and width limits across 0/1/20/39/40/60/80/120 columns.
- Focused strict TypeScript check passes using the installed Pi/TUI declarations and Node types (`/tmp/pi-companion-tsconfig.json`). No packages installed.
- Real auto-discovered Pi sessions at 60/80/120 columns pass startup/footer coexistence, pause with no redraws, hide/show/resume, reload, resize to 39 columns and back, multiline draft entry, cancellation, and clean exit. Harness `/tmp/pi-companion-pty-check.py`; captures `/tmp/pi-companion-{60,80,120}-pty.log`.
- Isolated real Pi + Powerline session passes deterministic working animation, waiting, native confirm/Escape/focus return, finished-to-ready, stopped, and error expressions. No model requests submitted. Harness `/tmp/pi-companion-fixture-check.py`; capture `/tmp/pi-companion-fixtures-pty.log`.
- Actual `pi --companion-static` starts paused and produces zero idle animation writes over 6.5 seconds; clean exit. Capture `/tmp/pi-companion-static-pty.log`.
- Task diff whitespace and local documentation links pass. The ignored Pi README was discovered during the task-scope status check and explicitly allowlisted in `.gitignore`.
- Still unverified: screenshot/contrast and mouse selection in the user's actual Tern window, real provider streaming/tool/diff/error rendering, and live Plannotator overlay coexistence. Native blocking-confirm coexistence was exercised, not every third-party overlay. A manual Tern pass remains necessary; do not call these checks complete.

The initial minimal configuration is implemented, not committed.
- Installed parser/layout merge and footer theme override loading pass assert-based checks. Segment fixtures pass for staged/unstaged/untracked markers, shell-mode labels, queue/blocked counts, review status, and context thresholds at 18/70/71/90/91 percent. Harness: `/tmp/pi-minimal-check.mjs` (temporary, not a repository test).
- Fresh Pi PTY sessions at 60/80/120 columns successfully launch, render the minimal footer, execute `/reload`, accept draft text, clear it, and exit with code 0. Captures: `/tmp/pi-minimal-{60,80,120}-pty.log`. No model requests were submitted.
- Not verified: visual appearance/contrast in actual Tern, multiline editing, selection, streaming/tool/diff/error interactions, or rendered active/long-status overflow. Extremely long individual segments can still be skipped by the installed footer even in wrap mode; addressing that requires a separately approved renderer change.

The user subsequently requested a fancy, unique UI with a logo, superseding the minimal-only direction, and explicitly selected the animated-companion style. The Pip design above is the proposed implementation of that preference.

Showcases researched from public upstream READMEs and, where noted, images:
- [pi-powerline-footer](https://github.com/nicobailon/pi-powerline-footer): already installed. Its `welcome.ts` includes a six-line block Pi logo in a pink-to-cyan gradient and a dismissible welcome overlay. Reuse is possible without a new package; arbitrary custom logo replacement is not a documented setting.
- [pi-ext](https://github.com/tomsej/pi-ext): README includes block-letter branding, a demo video, tool pills, and a leader-key palette. Inspiration only; do not install its full workflow suite or assume compatibility.
- [pi-workstation](https://github.com/marv1nnnnn/pi-workstation): inspected `assets/screenshot.png`; warm dark palette and animated companion/activity area. Distinctive but installing it also adds unrelated music/feed/workflow features.
- [Synthwave 84](https://github.com/robzolkos/pi-theme-synthwave-84): inspected `assets/preview.png`; cyan/pink colors and bright input borders. The large landscape in the screenshot is message image content, not a persistent UI background.

The user declined the proposed neon-cockpit direction in favor of an animated companion. Reuse the minimal footer as the functional base and add Pip's small native widget; do not install showcase bundles or copy their unrelated features.

Browser automation was not used because the installed Aside CLI reports an update prerequisite; public sources were fetched directly without updating tools.

## Approval boundary

The original minimal configuration and this companion revision were each approved. The companion approval is recorded in `/tmp/pi-companion-plan-decision.json` and the user's explicit approval in this conversation. This authorizes local implementation only, not a commit or PR.

The earlier Tern note remains recorded: Tern is the main environment, with Herdr/Muxy integrations desirable where appropriate. All existing integration exclusions stay intact here. Herdr is environment-gated; Muxy has no equivalent guard. Safe environment-dependent IPC integrations require a separate scope, and the mascot does not claim to implement them.
