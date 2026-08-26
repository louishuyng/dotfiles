---
name: tech-doc-writer
description: Use when writing or reviewing a technical document — design doc, RFC, ADR, README, runbook, API reference, postmortem, migration guide — or when a system needs a diagram to be understood.
---

# Tech Doc Writer

Write like a senior engineer at Google: the reader's time is the scarce resource. A doc succeeds when its audience can make a decision or complete a task without asking you a follow-up question.

Distilled from [Google's technical writing courses](https://developers.google.com/tech-writing/overview). Follow the links when a rule needs its worked examples.

## When to use

- Design docs, RFCs, ADRs, proposals — anything asking people to agree to something
- READMEs, runbooks, onboarding, API references, migration guides
- Postmortems, PR descriptions, and long code comments
- Reviewing someone else's doc, including your own draft

Not for: chat replies, commit subject lines, marketing copy.

## 1. Decide the audience before the first sentence

- Name the reader and what they already know. Everything obvious to you is invisible to them — the curse of knowledge is the top cause of unusable docs. ([audience](https://developers.google.com/tech-writing/one/audience))
- Write the goal in one sentence: after reading this, the reader can **X**.
- State scope **and** out-of-scope explicitly. Out-of-scope prevents more review churn than any other section. ([documents](https://developers.google.com/tech-writing/one/documents))
- Put the key point first — title and opening paragraph should carry the takeaway alone.

## 2. Words and sentences

| Rule | Why |
|---|---|
| Define each new term once, then use that exact term everywhere | Synonyms read as different concepts ([words](https://developers.google.com/tech-writing/one/words)) |
| Active voice: actor, verb, target | Passive hides who does what ([active voice](https://developers.google.com/tech-writing/one/active-voice)) |
| One idea per sentence | Long sentences hide the second idea ([short sentences](https://developers.google.com/tech-writing/one/short-sentences)) |
| Pick the strong verb; cut "there is/are", nominalizations, filler | `The service retries` beats `A retry of the request is performed` ([clear sentences](https://developers.google.com/tech-writing/one/clear-sentences)) |
| Turn a sentence with `and`/`or` chains into a list | Lists are scannable; prose is not |
| Numbered list for ordered steps, bullets otherwise; keep items parallel; start steps with an imperative verb | ([lists and tables](https://developers.google.com/tech-writing/one/lists-and-tables)) |
| Table when comparing along more than one dimension | Prose comparisons force the reader to hold state |
| First sentence of a paragraph states its point; 3–5 sentences; answer what / why / how | ([paragraphs](https://developers.google.com/tech-writing/one/paragraphs)) |
| Spell out an acronym on first use, then use it consistently — or don't introduce it at all | |

## 3. Diagrams

A diagram earns its place when the relationship is hard to hold in a sentence: control flow, message ordering, data shape, system boundaries. Decoration is noise. ([illustrating](https://developers.google.com/tech-writing/two/illustrations))

- **One message per diagram.** Cap it at roughly one paragraph of information, or five bullets of explanation. More than that means split it into subsystems.
- **Context first.** A big-picture diagram establishes boundaries, then per-subsystem diagrams go deep.
- **Caption below, a few words, stating the takeaway** — not "Figure 3: architecture".
- **Direct attention.** One highlight that breaks the pattern (a colored outline, an arrow, a callout) beats a paragraph of "note that on the left...".
- **Color is redundant.** It must survive grayscale and meet contrast requirements; never encode meaning in color alone.
- **Default to Mermaid** in the repo — it diffs in review and renders in GitHub and most wikis. Reach for a drawing tool and export SVG only when Mermaid can't express the shape.

Pick the type by the question the reader is asking:

| Question | Diagram |
|---|---|
| What calls what, in what order? | `sequenceDiagram` |
| What are the branches and decisions? | `flowchart` |
| What are the states and transitions? | `stateDiagram-v2` |
| How is the data related? | `erDiagram` |
| What is inside our boundary, what is outside? | `flowchart` with subgraphs (C4-context style) |

## 4. Self-edit before anyone else reads it

Do this pass every time — it is where the quality comes from. ([self-editing](https://developers.google.com/tech-writing/two/editing))

1. Step away, then reread as the audience you named in step 1.
2. Cut 10% of the words. There is always 10%.
3. Skim test: read only headings and first sentences. Does the argument still stand?
4. Verify every claim, link, command, and code sample. Run the samples.
5. Ask someone outside the team where they got confused, and fix that spot — not the sentence you were proud of.

## Checklist

- [ ] Audience and goal named; scope and out-of-scope stated
- [ ] Takeaway in the title and first paragraph
- [ ] Terms defined once and used consistently
- [ ] Active voice, one idea per sentence, no filler
- [ ] Steps as numbered lists; comparisons as tables
- [ ] Each diagram carries one message and a caption; readable in grayscale
- [ ] Samples run; links resolve
- [ ] Cut 10% and passed the skim test

## Common mistakes

| Mistake | Fix |
|---|---|
| Doc opens with background and buries the ask | Ask first, background after |
| The same thing called three names | Pick one term, grep the doc for the others |
| One diagram of the entire system | Context diagram + one per subsystem |
| Diagram with no caption, or a caption that names it | Caption states what to conclude |
| "Simply", "just", "obviously" | Delete — they only tell a stuck reader they are stupid |
| Options listed with no recommendation | Recommend one, state the trade-off |
| A wall of prose that is really 5 sequential steps | Numbered list |

For document skeletons (design doc, RFC, ADR, README, runbook, postmortem) and Mermaid starters, see [templates.md](templates.md).
