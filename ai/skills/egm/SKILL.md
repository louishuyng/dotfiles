---
name: egm
description: Elephant-Goldfish Model (EGM) design workflow with fresh-context reviewers. Use when the user asks for egm or one of its steps — brainstorm, draft, review, review-loop, resolve, bootstrap, or drift-report — for example "egm review design.md" or "run an EGM drift report on this ADR". Skip it when the native EGM plugin already exposes `egm:egm-*` skills in this session.
---

# EGM

EGM is vendored at `~/.dotfiles/ai/vendor/egm` (the plugin root; source and
commit in `vendor.json`). Its skills expect to run from that root.

1. Pick the step the user asked for: `egm-brainstorm`, `egm-draft`,
   `egm-review`, `egm-review-loop`, `egm-resolve`, `egm-bootstrap`, or
   `egm-drift-report`. If unclear, ask which one.
2. Read `~/.dotfiles/ai/vendor/egm/skills/<step>/SKILL.md` and follow it.
3. Resolve every path it names against the plugin root, not the user's project:
   `agents/…`, `resources/…`, `docs/…`, `../../docs/…`, and
   `${CLAUDE_PLUGIN_ROOT}/…` all mean `~/.dotfiles/ai/vendor/egm/…`.
   Read the harness note it points to (`docs/codex.md`, `docs/claude.md`, or
   `docs/harnesses.md` for other agents).
4. Named `egm-*` subagents are not registered outside the native plugin. Spawn
   a general-purpose subagent and tell it to read the persona file in
   `~/.dotfiles/ai/vendor/egm/agents/` first, as EGM's fallback describes.
5. No subagent tool in this agent: stop and say so. A review in the same
   context is not a Goldfish review.

Output files (briefs, drafts, reports) go in the user's project, not the vendor folder.
