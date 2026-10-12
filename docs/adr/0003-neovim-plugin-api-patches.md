# Preserve Neovim plugin behavior with local API patches

Accepted on 2026-10-12. The dotfiles owner wants deprecated API calls removed
without losing the current icons, mappings, or plugin behavior.

## Decision

Keep compatibility diffs in `nvim/patches`. Apply them before each affected
plugin loads and after `vim.pack` installs or updates it. Replace obsolete
calls with current Neovim APIs; keep validation, defaults, and recursive
flattening semantics. Do not suppress deprecation reporting.

Also guard Snacks readiness probes with the module's enabled state. Disabled
modules still report that status; genuine errors in enabled modules remain
visible. This fixes a false notification-readiness error when nvim-notify owns
`vim.notify`.

Cache a hash of each patch and its target files under Neovim's state directory.
Unchanged files require no Git subprocesses on later startups. Check each diff
before applying it. An already-applied diff succeeds without modifying files;
an incompatible upstream revision produces a warning for review.

## Alternatives and trade-offs

Maintained replacements reduce local maintenance but can change icon sets and
editor behavior. Broad plugin updates can also change unrelated features. The
owner approved narrow local patches instead. Remove a patch once the upstream
version supplies equivalent API fixes; retain it while preserving behavior is
the priority.

## Verification and rollback

Run the performance regression checks and exercise Git, file browsing, color
highlighting, and completion before checking `vim.deprecated`. Compare attached
UI rendering and startup timings after patches have been cached.

To roll back, remove the patch loader and restore the affected plugin files
from their installed Git revisions. The patch files record every source change.
Do not reset unrelated local plugin modifications.
