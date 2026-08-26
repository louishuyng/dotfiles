---
name: map-codebase
description: Use when you need to understand an unfamiliar or drifted codebase as an architect would — its modules, dependency direction, boundaries, and end-to-end flows — and want that understanding written to docs/codebase-infra/ as reusable reference and howto recipes. Safe to rerun; refreshes only what changed.
---

# Map Codebase

Read a codebase the way a senior engineer joining the team reads it: structure
first, dependency direction second, one real end-to-end trace third. Then write
down only what the code does not already say itself, in `docs/codebase-infra/`.

**Read-only on source.** This skill never edits, fixes, or refactors product
code. It writes `docs/codebase-infra/` and nothing else.

## Output layout

```
docs/codebase-infra/
  README.md          # index + run stamp + how to navigate
  architecture.md    # layers/rings, dependency direction, one diagram
  map.md             # one row per module: owns / depends on / entry point
  conventions.md     # rules that are actually enforced, and by what
  flows/             # end-to-end traces, one file per flow
  howto/             # task recipes, one file per repeatable task
```

No other top-level files. If a page would be under ~20 lines, fold it into its
parent instead of creating it.

## Procedure

### 1. Decide: first run or rerun

Read `docs/codebase-infra/README.md`. If it exists it carries a run stamp:

```
<!-- map-codebase: commit=<sha> date=<YYYY-MM-DD> -->
```

- **No stamp / no folder** → first run, do steps 2–6 in full.
- **Stamp present** → rerun. Get changed paths with
  `git diff --name-only <sha>..HEAD`. Regenerate only pages whose `Sources:`
  list intersects those paths, plus `map.md` if any module was added or
  removed. Leave every other page byte-identical. Update the stamp last.

If the diff is empty, say so and stop. Do not rewrite unchanged pages.

### 2. Structure before code

Cheap, high-signal reads, in this order. Stop as soon as the picture is clear:

1. Workspace manifests — `pnpm-workspace.yaml`, `go.work`, `turbo.json`, root
   `Makefile`. These name the real module boundaries; your own guess does not.
2. `tsconfig.json` path aliases and package `exports`/`imports` maps. These are
   the *declared* dependency graph and the enforced public surface.
3. Existing docs: `README.md`, `AGENTS.md`/`CLAUDE.md`, `docs/adr/`, and any
   `docs/*/architecture.md`. **Link to these, never restate them.** An ADR is
   the authority on its own decision.
4. Any boundary/lint verifier the repo runs in CI. What it forbids is a
   convention; what it permits is not.

### 3. Trace the real dependency direction

Declared aliases lie by omission. Confirm direction from actual imports:

```bash
grep -rho "from '[@#][^']*'" <module>/src --include='*.ts' | sort -u
```

Record for each module: what it owns, what it imports, who imports it, and its
entry point. An import that crosses a declared boundary is a finding — note it
in `architecture.md` under a "Known violations" heading with the file path.
Do not fix it.

### 4. Trace one flow end to end, per surface

Pick the flow the product actually lives on, per surface (client, HTTP, job,
CLI). Follow it file by file from the outermost entry point to persistence and
back. Read the real files; do not infer a middle step.

Write each as `flows/<name>.md`: numbered hops, each hop a `path:line` and one
sentence on what it does to the data. Failure path included — where does an
error become a response? That is the part nobody can reconstruct from grep.

### 5. Derive howtos from evidence, not imagination

**A howto needs at least two existing examples in the repo.** One example is an
instance, not a pattern; zero examples is you inventing an API. If you can only
find one, write the flow instead and say a pattern has not settled.

Find candidates by looking for what repeats: sibling route files, sibling
migrations, sibling screens, sibling adapters. Each recurring shape is one
howto. Typical set for a full-stack repo — generate only the ones the code
supports:

- `howto/add-a-route.md`
- `howto/implement-a-backend-feature.md`
- `howto/add-a-database-table.md` (schema + migration + repository)
- `howto/add-a-screen.md`
- `howto/add-a-package.md`
- `howto/add-an-external-adapter.md`
- `howto/run-and-verify-locally.md` (the commands CI runs, in CI's order)

Each howto is a **checklist of files to touch, in order**, each step naming a
real path and the existing file to copy from. Finish with the verification
command that proves it worked. No prose introduction.

```markdown
# Add a route

Reference: `packages/api/src/routes/foo.ts` (simple), `.../bar.ts` (with auth)

1. Contract — add the schema to `packages/contracts/src/...`. Copy the shape of X.
2. Handler — new file at `...`. Parse input at the boundary; return a Result.
3. Register — add to `...` (the only place routes are mounted).
4. Test — `packages/api/tests/...`, mirroring `foo.test.ts`.
5. Verify — `make -C packages/api verify`

Gotchas: <only non-obvious ones, with the reason>

Sources: packages/api/src/routes/, packages/contracts/src/
```

### 6. Write the index and stamp it

`README.md` lists every page with a one-line "read this when…" and carries the
run stamp comment from step 1.

## Rules for the writing

- **Every page ends with `Sources: <paths>`.** This is what makes a rerun
  cheap. A page without sources can never be refreshed and must be deleted.
- **Cite `path:line` for any specific claim.** A claim you cannot cite is a
  guess — either verify it or write "unverified:" in front of it.
- Prefer a table over paragraphs for anything enumerable.
- One Mermaid diagram in `architecture.md`; more than one means the split is
  wrong. None elsewhere unless a flow is genuinely non-linear.
- Never restate what the code, an ADR, or the README already says. Link.
- No "Overview"/"Introduction"/"Conclusion" sections. Start at the content.
- Match the repo's existing doc conventions (heading style, date format,
  relative links) — check a neighbouring `docs/` file before writing.

## Scaling

Large monorepo (10+ modules)? Read manifests and aliases yourself first, then
dispatch one read-only exploration agent per module with a fixed return shape:
`{owns, imports, imported_by, entry_point, notable}`. Synthesise `map.md` from
the returns. Never delegate step 4 — the end-to-end trace is the one part that
needs a single head holding the whole path.

## Common mistakes

| Mistake | Fix |
|---|---|
| Howto invented from one example | Two examples or it is a flow, not a howto |
| Restating an ADR in `architecture.md` | Link the ADR, record only what it left open |
| Page with no `Sources:` | Unrefreshable on rerun — add sources or delete |
| Rerun rewrites everything | Diff against the stamp; touch only affected pages |
| Fixing a boundary violation you found | Record it, do not fix it. Different task. |
| A `flows/` file that skips a hop | Every hop is a real `path:line` you opened |
