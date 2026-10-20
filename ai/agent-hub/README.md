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

To use **http://agent-hub.localhost** without a port, run `npm run service -- clean-url` in Terminal and enter your macOS administrator password when Portless requests it. This installs Portless's system startup service on loopback HTTP port 80, replaces the user proxy, and keeps the application running under your user at login. It requires an available port 80 and refuses to replace a system Portless service using another state directory. Subsequent installs preserve the clean URL. Uninstalling this system proxy also requires administrator authorization. No TLS certificate is installed.

Setup reads the repository manifest and applies its global enabled set before installing the service. The dotfiles bootstrap runs the same dependency/build/setup/service sequence with `bash bootstrap/mac.sh --tasks agent_hub` (use the wrapper's `--help` for platform/preview flags).

For development, run `npm start` and `npm run dev` in separate terminals. The Vite development UI proxies `/api` to the local service on port 4310.

## Shared skills and configuration

Use **Shared setup** to add, edit, enable, disable, or remove shared MCP servers
and shared hooks. The source of truth is
[`ai/config/shared-setup.json`](../config/shared-setup.json). The page links to
the existing shared skill library and shows per-agent MCP/hook sync results.
Cursor joins through `~/.cursor` detection; installing its CLI is unnecessary.

Saves sync immediately. Startup and the 60-second maintenance loop apply source
edits and include newly detected supported agents. New skills and enablement
changes also activate skill sharing automatically. Native conflicts remain
untouched and appear as blocked targets. Additional native servers prevent a
verified shared set; import compatible entries explicitly from the page.

Shared servers support stdio commands and Streamable HTTP endpoints. Native-only
options and environment interpolation require manual setup and appear as
incomplete parity. Shared command hooks map supported tool-use and completion
events. ADHD, Ponytail, Plannotator, and the conditional `ui-frontend` workflow default
on. The Hooks workspace stores global defaults and per-agent opt-outs while
keeping one shared body for each hook.
Context hooks run in Codex, Claude, Gemini, Cursor, OpenCode, Pi, and omp. Commands receive native JSON; they
must handle each runtime's payload and output contract. Unsupported agents and
events remain visible. Restart agents after configuration changes and use their
native tools to check connections, OAuth, and project overrides.

Do not put secrets in repository-owned MCP definitions or hook commands.
Private backups and interrupted-write journals live under
`~/.local/share/agent-hub/shared-backups/` and `shared-pending.json`.
Restart Agent Hub to recover interrupted writes. If recovery reports an external
change, preserve the journal and affected files before repairing the conflict.
Backups contain `changes` entries with each file's `before` and `after` content;
restore only the intended managed section after comparing the current file.
See [the shared setup decision](../../docs/adr/0006-shared-agent-setup.md).

Native Codex plugins remain managed through the app server. Skill creation, edits, and enablement use the repository library and manifest.

The current manifest enables eleven skills: archify, aside-browser, better-write, caveman, herdr-implement, herdr-plan, i-have-adhd, plannotator, ponytail, tech-doc-writer, and ui-ux-pro-max. The repository-owned [Plannotator skill](../skills/plannotator/SKILL.md) defines the shared review policy and supplies its hook body. Setup moves inactive source folders out of the active library into `~/.local/share/agent-hub/disabled-skills/<timestamp>/` and prints that private recovery path. Future toggles change the manifest; consult it instead of assuming the count stays eleven.

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

The optional Plannotator hook requests local browser review before creating or
marking a PR ready. Follow the [shared review skill](../skills/plannotator/SKILL.md)
for exact task-only scope selection, launch commands, feedback handling, and the
explicit human conversation-approval requirement. PR creation needs separate
authorization; Agent Hub creates no PR automatically.

Install the standalone binary pinned to **v0.28.23**, using the upstream
installer's `--minimal --version 0.28.23` options. Do not install automatic plan
hooks or extra skills. Reviews bind loopback, disable sharing and surprise
browser/Glimpse launches, and open the actual printed URL. The CLI returns its
decision/message JSON via stdout and exits; after fixes, rerun relevant checks
and reopen the final diff. No guided review or automatic AI reviewer is required.
Standalone Ask AI uses the selected provider; Codex runs in a separate read-only
session. The optional native omp/Pi integration uses
`@plannotator/pi-extension@0.28.23` through each host's
official package manager: `omp plugin install @plannotator/pi-extension@0.28.23`
or `pi install npm:@plannotator/pi-extension@0.28.23`. Its
`/plannotator-review`, `/plannotator-annotate`, and `/plannotator-last` commands
provide the native same-session bridge; the standalone CLI does not. Native Q&A
runs a real agent turn with tools and transcript access, not a read-only fallback.
Restart affected agents after native package installation. Agent Hub source
upgrades follow the existing build/restart runbook; do not restart Portless.
Fresh omp command discovery, same-session Q&A, and inline-feedback delivery were
verified. Pi command discovery was verified; its Q&A was not exercised separately.
The human must handle provider permission prompts; agents must not autoapprove.
Do not enable `--plan` or add automatic plan hooks. Provider-backed AI can disclose
relevant code; the app's release check means local review is not fully offline.

Disable Plannotator for an agent in Hooks to opt out. Start a new session after
changing context hooks; existing conversations can retain earlier text. This is
an instruction, not an enforced GitHub gate. See the
[accepted review decision](../../docs/adr/0006-shared-agent-setup.md#accepted-update-plannotator-replaces-difit-globally).

## Shared hook sources and cleanup

In **Hooks → Add hook**, choose **Context text**, **Skill reference**, or
**Command**. Text hooks store instructions in shared configuration. Skill hooks
reference a name from the shared library and load its current `SKILL.md` body,
without running its scripts. Both inject context at session start. Command hooks
run at the selected native event. Review the diff before saving; supported
agents receive the hook and can opt out individually. **View context** shows
the exact injected text and source, and **Edit context** edits that source.

ADHD reads `ai/skills/i-have-adhd/SKILL.md`; Ponytail reads
`ai/skills/ponytail/SKILL.md`; Plannotator reads `ai/skills/plannotator/SKILL.md`. Their global
enabled state and `disabledAgents` lists live in `ai/config/shared-setup.json`.
The shared instructions in `ai/AGENTS.md` contain neither an always-on ADHD output
policy nor a mandatory review rule.

`ui-frontend` is a context-text hook in `ai/config/shared-setup.json`. Its workflow
activates only for tasks that design, build, change, or review UI/frontend work.
It requires the installed `ui-ux-pro-max` skill and relevant design/stack skills,
then applies the relevant [Front-End Checklist](https://github.com/thedaviddias/front-end-checklist)
rules to frontend changes. Existing checklist skills/MCP tools can supply rules;
otherwise agents read the checklist directly. It does not install integrations,
upload private code, or start a site-wide audit automatically.

Backend-only, database, infrastructure, and unrelated documentation/script tasks
skip design-skill loading and checklist retrieval. Mixed tasks apply the workflow
only to their UI/frontend portion. The short conditional requirement also lives
in `ai/AGENTS.md` for instruction consumers without hook support. Disabling the
hook removes its detailed workflow, not that shared instruction. Context text is
delivered at session start; task scoping is an agent instruction, not runtime
task detection or an enforcement gate.

Copilot CLI and Droid receive the conditional requirement through personal
instructions instead of a shared context hook:
[`~/.copilot/copilot-instructions.md`](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)
and [`~/.factory/AGENTS.md`](https://docs.factory.com/harness/agents-md).
Agent Hub links both to `ai/AGENTS.md` when their configuration directories
exist, using the existing global-file backup and reconciliation flow.
Their unsupported hook status does not mean those instruction links are absent.
SuperGrok web still has no local instruction-sync bridge.

The shared context runner generates each native output shape. OpenCode uses the
repository `shared-hooks` plugin; Pi uses `ai/hooks/pi-extension.ts`, registered
through `ai/config/native-pi-extensions.json`. omp uses `ai/hooks/omp-extension.ts`,
registered in `ai/config/native-omp.yml`, linked to
`~/.omp/agent/config.yml` by the bootstrap `ai` task. The same task links OMP's
keybindings, MCP config, shared instructions, and skills; it preserves an
existing Agent Hub skills link. Restart omp after restoring a missing extension;
modules absent at startup cannot be loaded into an existing session.

omp's project-focused `Ctrl+G` also requires
`ai/config/native-omp-keybindings.yml` at `~/.omp/agent/keybindings.yml`; it
disables the built-in temporary draft editor so the shared extension can open
the matching Zed project. See [the Tern shortcut setup](../../terminals/herdr/README.md#tern).

Legacy Superset, Herdr, RTK,
Caveman, and duplicate Crit registrations were removed from the managed native
hook sources. Duplicate Ponytail/ADHD plugin providers are disabled so their
hooks cannot bypass the workspace switches. Pi's old Herdr and notification
extensions are excluded; their files remain available for recovery.
