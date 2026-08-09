# Plan template

A plan is the product. Write it for an executor that is **less capable than you, has never seen this repo, and cannot ask you questions**. Every ambiguity you leave becomes an improvisation you won't like.

## The standard

Before you write, and again before you finish, check the plan against these:

1. **Self-contained.** No reference to "the audit," "as discussed," "the other plan," or anything outside this file. If plan 004 depends on 002, restate what 002 established — don't link and hope.
2. **Excerpts are real.** Every quoted snippet was read by you from the file at the recorded commit, with correct paths and line numbers. Never copy an excerpt out of a subagent report.
3. **Every step is verifiable.** A step whose success can't be checked by a command is a step the executor will claim to have done.
4. **Scope is fenced.** Say what's out of scope, especially the tempting adjacent things.
5. **Failure has an exit.** The executor must know when to stop and report rather than improvise.
6. **No secret values.** Reference credential locations and types only.

Aim for a plan a careful junior engineer could execute on a Friday afternoon without pinging anyone.

---

## Template

Copy this structure into `plans/NNN-<slug>.md`. Drop sections that genuinely don't apply; don't drop them because they're hard.

````markdown
# NNN — <Imperative title: "Fix duplicate user creation under concurrent signup">

- **Status:** TODO <!-- TODO | IN PROGRESS | DONE | BLOCKED | STALE -->
- **Category:** correctness
- **Severity:** high
- **Effort:** M
- **Fix risk:** medium
- **Written against commit:** `a1b2c3d`
- **Depends on:** none <!-- or: 002 (characterization tests for UserStore) -->
- **Issue:** <!-- URL, if published with --issues -->

## Problem

What is wrong, in plain language, with enough background that someone who has never
opened this repo understands why it matters. Two to five sentences.

Include the concrete failure: who hits it, under what conditions, what they observe.

## Evidence

`src/services/user.ts:88-104` — the uniqueness check and the insert are separate awaits
with no transaction or DB constraint between them:

```ts
const existing = await db.user.findUnique({ where: { email } })
if (existing) throw new ConflictError('email taken')
return db.user.create({ data: { email, name } })
```

`prisma/schema.prisma:22` — `email` is declared `String` with no `@unique`.

<!-- Real excerpts, read by you, at the commit above. Enough to orient, not a file dump. -->

## Why this approach

The fix shape and the alternatives you rejected, with the reason. One short paragraph.
The executor needs this to make micro-decisions consistently with your intent — and to
recognize when reality contradicts the assumption behind the approach.

## Repo conventions to follow

Concrete and specific to this repo, with an exemplar the executor can open and imitate:

- Migrations live in `prisma/migrations/`, created with `pnpm prisma migrate dev --name <name>`.
- Domain errors extend `AppError` — see `src/errors/conflict.ts` for the shape.
- Service functions take a `tx` parameter when they may participate in a transaction;
  `src/services/order.ts:40-72` is the pattern to copy.
- Tests use Vitest with `describe`/`it`, colocated as `*.test.ts` next to the source.
  Follow `src/services/order.test.ts`.

## Files in scope

- `prisma/schema.prisma` — add the unique constraint
- `prisma/migrations/` — new migration (generated, do not hand-write)
- `src/services/user.ts` — handle the constraint violation
- `src/services/user.test.ts` — new tests

## Out of scope — do not touch

- `src/services/order.ts` — has the same check-then-act shape; it's tracked separately
  in plan 005. Leave it alone even though it looks identical.
- Any change to the `AppError` hierarchy.
- Reformatting, renaming, or "while I'm here" cleanups anywhere.

## Steps

### 1. Add the unique constraint to the schema

In `prisma/schema.prisma:22`, add `@unique` to the `email` field.

Verify:
```bash
pnpm prisma validate
```
Expected: `The schema at prisma/schema.prisma is valid 🚀`

### 2. Generate the migration

```bash
pnpm prisma migrate dev --name unique_user_email
```
Expected: a new directory under `prisma/migrations/` containing a `CREATE UNIQUE INDEX`
statement on `User(email)`.

**If the migration fails because existing rows violate the constraint: STOP and report
back.** Deduplicating production data is a separate decision, not part of this plan.

### 3. Handle the constraint violation in the service

...

<!-- Each step: what to change, where, and a command with expected output.
     Steps are ordered and independently checkable. Prefer more, smaller steps. -->

## Test plan

- `src/services/user.test.ts` — add a test that two concurrent `createUser` calls with
  the same email produce exactly one row and one `ConflictError`. Follow the concurrency
  test in `src/services/order.test.ts:110-140` for the `Promise.allSettled` pattern.
- Existing tests in that file must keep passing unchanged. If one now fails, that's
  signal about a behavior change — report it, don't edit the test to match.

## Done criteria

All of these must pass, from the repo root:

```bash
pnpm typecheck          # exits 0, no errors
pnpm lint               # exits 0
pnpm test src/services/user.test.ts   # all pass, including the new concurrency test
pnpm test               # full suite, no new failures vs. the baseline
```

Plus:
- `git diff --name-only` lists only files from "Files in scope".
- The generated migration is committed alongside the schema change.

## Escape hatches

STOP and report back instead of improvising if:

- The migration can't apply because of existing duplicate rows (step 2).
- The full test suite was already failing before your changes — record the baseline
  failures first and say so; don't try to fix unrelated ones.
- Fixing this requires changing a file listed as out of scope.
- Any step's verification command produces output you can't reconcile with the expected
  output above — the plan may be stale relative to the current code.

## Drift check

This plan was written against commit `a1b2c3d`. Before starting:

```bash
git log --oneline a1b2c3d..HEAD -- src/services/user.ts prisma/schema.prisma
```

If that lists commits, the excerpts above may no longer match. Read the current files
first; if the code has materially changed, report that instead of executing.

## Maintenance note

Once `email` is unique at the DB level, any future code path that creates users must
handle the constraint violation rather than pre-checking. Reviewers should watch for
new check-then-act patterns against `User`. Plan 005 applies the same treatment to
`Order`; when it lands, the shared error-mapping helper introduced here should be
reused rather than duplicated.
````

---

## `plans/README.md`

The index. Executors read this first to pick work, and update the status column as they go.

````markdown
# Improvement plans

Generated by `improve` on <date>, against commit `a1b2c3d`.
Audit scope: <what was audited> — **not audited: <what wasn't, and why>**.

## Execution order

Follow the order below. Dependencies are hard — do not start a plan whose
dependencies are not DONE.

| #   | Plan                                  | Category    | Effort | Risk   | Depends on | Status |
| --- | ------------------------------------- | ----------- | ------ | ------ | ---------- | ------ |
| 001 | [Establish test baseline](001-….md)   | tests       | M      | low    | —          | TODO   |
| 002 | [Fix duplicate user creation](002-….md)| correctness | M      | medium | 001        | TODO   |

Status values: `TODO` → `IN PROGRESS` → `DONE`, or `BLOCKED` (add a one-line reason
in the plan file) or `STALE` (code moved under it; needs a refresh before execution).

## Dependency graph

```
001 ──▶ 002 ──▶ 005
   └──▶ 003
004 (independent)
```

## Direction suggestions (not plans)

Options for the maintainer, not defects. Recorded here so they aren't re-derived
next run.

- **<Suggestion>** — evidence, trade-off, coarse effort. (1–3 sentences.)

## Considered and rejected

Findings that were audited and deliberately not planned. Recorded so future runs
don't re-surface them.

| Finding                        | Why rejected                                        |
| ------------------------------ | --------------------------------------------------- |
| Sync write in `store.ts`       | Documented tradeoff in `docs/adr/0004-sync-io.md`.   |
| `https_proxy` treated as SSRF  | By design — standard proxy convention.              |
````
