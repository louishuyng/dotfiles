# Agent Hub: manage LX14-AI-Skills locally

Open **http://agent-hub.localhost:1355** to manage this Mac's agent setup. This runbook is for the dotfiles owner: use it to rebuild the app, inspect its background services, and restore configuration.

**LX14-AI-Skills** is the repository library at [`ai/skills`](../skills). Its [`manifest.json`](../skills/manifest.json) defines the enabled set. Codex Desktop consumes this library; its discovered catalogue does not define the shared source.

The local React/TypeScript dashboard manages skills, plugins, hooks, and instructions. Daily and Monday-based weekly metrics come from Codex, Claude Code, OpenCode v2, and Pi history. The 21-tool catalogue uses bundled brand icons and shows each tool's actual capabilities.

## Run and update

Requires macOS, Node 24+, Portless, and Codex CLI with app-server support.

```sh
cd ~/.dotfiles/ai/agent-hub
npm ci
npm run build
node scripts/setup.mjs
npm run service -- install
npm run service -- status
```

Two user LaunchAgents start the isolated Portless proxy and compiled application at login. Both restart after failures. The proxy binds loopback on port 1355 and uses its own state directory; other Portless apps retain their settings. Rebuild after source changes, then run `npm run service -- restart`.

Setup reads the repository manifest and applies its global enabled set before installing the service. The dotfiles bootstrap runs the same dependency/build/setup/service sequence with `bash bootstrap/mac.sh --tasks agent_hub` (use the wrapper's `--help` for platform/preview flags).

For development, run `npm start` and `npm run dev` in separate terminals. The Vite development UI proxies `/api` to the local service on port 4310.

## Shared skills and configuration

Native Codex plugins remain managed through the app server. Skill creation, edits, and enablement use the repository library and manifest.

The current manifest enables ten skills: archify, aside-browser, better-write, caveman, crit, crit-cli, crit-story, ponytail, tech-doc-writer, and ui-ux-pro-max. The three Crit skills and the Ponytail 5.1.0 base skill are repository copies with their licenses. Setup moves inactive source folders out of the active library into `~/.local/share/agent-hub/disabled-skills/<timestamp>/` and prints that private recovery path. Future toggles change the manifest; consult it instead of assuming the count stays ten.

Use **Skills → Review sync** to preview and apply shared links. Codex's `~/.agents/skills`, Claude's `~/.claude/skills`, OpenCode's `~/.config/opencode/skills`, and configured compatible targets receive exports of the same enabled repository folders. Scripts and relative references stay with each skill. Source edits happen in `ai/skills`, not a tool's plugin cache. Exports use skill names; ambiguous names fail before writing. Sync stages targets, reverses failed swaps, journals interrupted changes, and refreshes managed exports after library changes. Displaced roots are backed up. Bootstrap preserves active Agent Hub links.

An equal export count does not prove an equal runtime skill set. Inspect each enabled-set check and its issues after refreshing. Missing, extra, unreadable, or differently resolved folders cause drift. Unsupported native skill sources prevent a verified total. Selected projects can introduce additional skills and require a separate project audit. Restart affected agents after changes, then inspect their native catalogues before claiming exact parity.

Setup suppresses competing global skill sources where supported. OpenCode's explicit vendor roots can override shared files; their configuration is backed up before removal. Pi package registrations use `skills: []`, and old global skill roots are excluded while extensions remain enabled. Claude plugins can bundle skills and hooks: disabling those plugins to remove extra skills also removes their hooks. Obtain owner agreement for that trade-off; keep exact Claude parity unverified while approval or audit remains incomplete.

After the owner accepts the coupled Claude hook removal, `node scripts/setup.mjs --strict-plugins` records that consent and disables skill-providing Claude plugins. Without that flag or recorded consent, setup preserves those plugins and reports any resulting mismatch.

Native plugins and hook formats remain separate from the library. Sharing instructions does not provide an unavailable connector or lifecycle runtime. SuperGrok web has no local skill or subscription-usage bridge. Catalogue-only tools use their native application until an adapter exists.

All editor saves show a diff, validate syntax, reject stale revisions, and preserve symlink targets. Native enablement toggles use supported Codex RPCs or the existing tool's configuration. Restart Claude/OpenCode after plugin changes. Configuration projections expose hooks/registrations instead of whole credential-bearing settings.

## Metrics and privacy

Metrics are recorded activity, not a subscription bill. Input totals include cache reads/writes; cache and reasoning are subsets, not extra tokens. Streaming/cumulative records and duplicate response IDs are deduplicated. Subagents stay identifiable. Context shows latest/peak recorded request input as a proxy; it does not claim measured context occupancy. Cost is unavailable unless the source records it, and coverage is shown separately.

The incremental SQLite cache stores metric metadata and file offsets, not prompts or responses. OpenCode's database is opened read-only. Dates use the machine timezone; weeks start Monday. Unsupported schemas, missing history, malformed records, and records above the 16 MB streaming limit produce visible warnings.

The API binds loopback, checks Host and Origin, and requires an in-memory token for writes. Runtime data lives under `~/.local/share/agent-hub/`: `state.json`, `cache/usage.sqlite`, `skills/`, `backups/`, and `logs/`. Backups contain original configuration and are private local files; do not commit or share them.

## Inspect, restore, and remove

```sh
npm test
npm run service -- status
npm run service -- restart
```

Inspect `~/.local/share/agent-hub/logs/dev.agent-hub.error.log` and `dev.agent-hub.proxy.error.log` if the URL fails. Use the editor's backup selector to restore a document after confirming its target and backup timestamp.

To undo skill-root sharing, stop the background jobs first, then restore preserved roots:

```sh
npm run service -- uninstall
npm run service -- restore-skills
```

Uninstall removes only the two login services. Configuration, skill sources, backups, and usage data remain. `restore-skills` recovers an interrupted sync journal and refuses to overwrite a root changed outside Agent Hub. It restores shared roots; separately restore native-source suppression settings from their configuration backups and removed repository folders from the private recovery backup. Review those changes before restarting agents.

Login configuration and immediate restart are tested without ending the desktop session. A real logout/login remains an owner check. Node's SQLite API is currently experimental; the cache is rebuildable.

See [the accepted architecture decision](../../docs/adr/0003-local-agent-hub.md) and [icon attribution](public/icons/ATTRIBUTION.md).

## Repository-owned global configuration

All global settings edited in Agent Hub live under `ai/`: the shared
`ai/AGENTS.md`, hooks in `ai/hooks/<tool>.json`, managed settings in
`ai/config/`, and editable OpenCode plugin implementations in
`ai/plugins/opencode/`. Existing OpenCode paths are compatibility symlinks.
Explicitly selected project instruction files remain in their projects.

Bootstrap and application startup link standalone instruction/hook files and
apply managed JSON sections to native settings. Background reconciliation runs
every 60 seconds. UI saves update both source and runtime immediately, reject
stale revisions, and preserve unrelated native fields. Full native settings and
credentials remain private; only the managed sections enter the repository.
Native plugin packages and vendor-owned hook executables remain in their native
installations. Displaced global files are preserved in the private
`original-global-files/` backup directory.

The shared instructions require approved Crit review before creating a PR.
Use Crit Story for 10+ changed files, 500+ added/deleted lines, or cross-cutting
architecture/interface changes. Generated, vendored, and lockfile changes do
not inflate the size threshold. Story preparation does not grant approval:
finish the interactive Crit loop, address comments, and review again after code
changes. This is an agent instruction, not an unbypassable GitHub or shell gate.
No PR is created automatically by Agent Hub.
