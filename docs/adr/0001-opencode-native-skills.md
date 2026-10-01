# Share Codex instructions and register OpenCode v2 hooks

Accepted on 2026-10-01. This decision helps the dotfiles owner maintain Ponytail
and ADHD mode alongside RTK in OpenCode v2.

Install the upstream repositories under `~/.config/opencode/vendor/`. Configure
their `skills/` directories. A local v2 plugin registers mode commands and context
hooks using Ponytail's instruction builder and the ADHD skill. Global
`~/.config/opencode/AGENTS.md` links to `~/.codex/AGENTS.md` so both agents share
the same instructions. The MCP configuration follows the existing Codex setup.

Ponytail 4.10.0 and ADHD 0.3.0 still export v1 hook functions, which v2 cannot run.
The owner chose upstream installations, then requested automatic hooks and shared
Codex instructions. V2 requires a plugin to register hooks. The small local plugins
add no package dependencies and leave upstream checkouts unchanged. Modes persist
per session in plugin storage. Ponytail uses its configured default; the OpenCode
ADHD always-on flag enables ADHD rules in new sessions.

RTK's supplied OpenCode plugin also uses v1 hooks. The local `rtk` plugin registers
v2's shell creation hook and delegates every rewrite decision to `rtk rewrite`.
Supported commands receive RTK filtering; already rewritten commands remain stable.
Unsupported commands and rewrite failures keep the original command. A context hook
loads `~/.codex/RTK.md` explicitly because OpenCode does not expand Codex's `@` reference
through its `instructions` config. Temporary read failures retain the last loaded rules.

Update each vendor checkout with `git pull --ff-only`, then reload OpenCode. Refresh
the remaining configured command templates if upstream changes them. Replace the
local plugins when upstream publishes compatible v2 entry points. Global Codex
instructions still apply when a session disables a plugin mode.

Verification covers active plugin registration, mode isolation and persistence,
RTK rewriting, unchanged unsupported commands, and failure fallback. To roll back,
remove the two local entries from `plugins` and unlink OpenCode's global `AGENTS.md`.
Configuration backups are under `~/.config/opencode/backups/`.

References: [Ponytail](https://github.com/DietrichGebert/ponytail),
[ADHD installation](https://github.com/ayghri/i-have-adhd/blob/main/INSTALL.md),
[RTK OpenCode hook](https://github.com/rtk-ai/rtk/blob/develop/hooks/opencode/rtk.ts),
[v2 plugin migration](https://opencode.ai/v2/docs/build/plugins/migrate-v1),
[v2 instructions](https://opencode.ai/v2/docs/instructions).
