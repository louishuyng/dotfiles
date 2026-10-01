# Maintain OpenCode configuration in dotfiles with four workflow roles

Accepted on 2026-10-01. The dotfiles owner needs one editable source for the active
OpenCode configuration and a shorter agent menu.

## Decision

Keep the source under `~/.dotfiles/opencode`, as requested by the owner after
considering `~/.dotfiles/ai/opencode`. Link the global `opencode.jsonc`, agent
profiles, shared instructions, and ADHD default flag to this source. Link skills
to the current `~/.dotfiles/ai/skills`; archive the old OpenCode skills directory.
Runtime files, credentials, vendor repositories, and backups remain under
OpenCode's existing local directories.

Use the built-in Build and Plan profiles plus custom Review and Research
profiles. Replace four domain-specific menu entries with these two workflow
roles. The owner approved this four-role menu. Shared skills provide the domain
expertise instead of separate backend/frontend/architecture profiles. Review and
Research deny edits, shell commands, child agents, and MCP actions; they do not
pin a model. Build remains the default.

Keep the `codex-modes` internal ID and plugin directory. The plugin implements
OpenCode v2 Ponytail/ADHD hooks, and preserving its ID avoids changing plugin
storage ownership. Document its responsibility rather than renaming persisted
state. RTK's separate hook and Caveman's on-demand command remain configured.

## Alternatives and trade-offs

A separate `ai/opencode` directory would also work, but the owner chose the
existing directory and symlink convention. Keeping six shortened menu names
would preserve domain profiles; four workflow roles reduce selection effort and
reuse current skills. If explicit domain workflows become necessary, add a
profile only when it provides behavior beyond a shared skill.

Review and Research are deliberately restricted. Review cannot run `git diff`
or tests and may require a supplied patch. These limits favor predictable
read-only behavior over autonomous validation; use Build when execution is needed.

## Verification and rollback

Check the live config's real path, shared skills and instructions, the four
visible primary agents, permission rules, model inheritance, active hook plugins,
and remaining MCP connections. Existing hook checks cover mode isolation,
persistence, RTK rewriting, and failure fallback. No model request is required.

The migration archive is
`~/.config/opencode/backups/before-dotfiles-link-20261001-164059/`. Restore the
saved config and archived agent/skills directories, restore their links, and
reload to return to the prior setup. Git changes preserve the bootstrap update
for review; unrelated dotfiles changes remain untouched.

References: [agent configuration](https://opencode.ai/v2/docs/agents),
[skill discovery](https://opencode.ai/v2/docs/skills), and
[global configuration](https://opencode.ai/v2/docs/config).
