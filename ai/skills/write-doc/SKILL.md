---
name: write-doc
description: Use when writing or reviewing anything a human will read — commit messages, error messages, UI text, explanations, reports, and technical documents such as a design doc, RFC, ADR, README, runbook, API reference, postmortem, or migration guide — or when a system needs a diagram to be understood. Applies Strunk's rules for clear prose, Google's technical writing rules for documents and diagrams, and requires every citation to be followable.
---

# Write Doc

Write with clarity and force. The reader's time is the scarce resource.

This skill has two parts. Use [Prose](#prose) for every sentence a human will read. Add [Technical documents](#technical-documents) when the output is a document or a diagram.

## When to use

- Commit messages, pull request descriptions, code comments
- Error messages, UI copy, help text
- Reports, summaries, explanations, and edits for clarity
- Design docs, RFCs, ADRs, proposals — anything asking people to agree to something
- READMEs, runbooks, onboarding, API references, migration guides, postmortems
- Reviewing someone else's writing, including your own draft

## Limited context strategy

When context is tight:

1. Write your draft using judgment
2. Dispatch a subagent with your draft and the relevant section file
3. Have the subagent copyedit and return the revision

Loading a single section (~1,000-4,500 tokens) instead of everything saves significant context.

## Prose

### Elements of Style

William Strunk Jr.'s _The Elements of Style_ (1918) teaches you to write clearly and cut ruthlessly.

**Elementary Rules of Usage (Grammar/Punctuation)**:

1. Form possessive singular by adding 's
2. Use comma after each term in series except last
3. Enclose parenthetic expressions between commas
4. Comma before conjunction introducing co-ordinate clause
5. Don't join independent clauses by comma
6. Don't break sentences in two
7. Participial phrase at beginning refers to grammatical subject

**Elementary Principles of Composition**:

8. One paragraph per topic
9. Begin paragraph with topic sentence
10. **Use active voice**
11. **Put statements in positive form**
12. **Use definite, specific, concrete language**
13. **Omit needless words**
14. Avoid succession of loose sentences
15. Express co-ordinate ideas in similar form
16. **Keep related words together**
17. Keep to one tense in summaries
18. **Place emphatic words at end of sentence**

The rules above are summarized from Strunk's original text. For complete explanations with examples, load a file from `elements-of-style/`:

| Section                                      | File                                           | ~Tokens |
| -------------------------------------------- | ---------------------------------------------- | ------- |
| Grammar, punctuation, comma rules            | `02-elementary-rules-of-usage.md`              | 2,500   |
| Paragraph structure, active voice, concision | `03-elementary-principles-of-composition.md`   | 4,500   |
| Headings, quotations, formatting             | `04-a-few-matters-of-form.md`                  | 1,000   |
| Word choice, common errors                   | `05-words-and-expressions-commonly-misused.md` | 4,000   |

**Most tasks need only `03-elementary-principles-of-composition.md`** — it covers active voice, positive form, concrete language, and omitting needless words.

### AI writing patterns to avoid

LLMs regress to statistical means, producing generic, puffy prose. Avoid:

- **Puffery:** pivotal, crucial, vital, testament, enduring legacy
- **Empty "-ing" phrases:** ensuring reliability, showcasing features, highlighting capabilities
- **Promotional adjectives:** groundbreaking, seamless, robust, cutting-edge
- **Overused AI vocabulary:** delve, leverage, multifaceted, foster, realm, tapestry
- **Formatting overuse:** excessive bullets, emoji decorations, bold on every other word

Be specific, not grandiose. Say what it actually does.

For comprehensive research on why these patterns occur, see `signs-of-ai-writing.md`. Wikipedia editors developed this guide to detect AI-generated submissions — their patterns are well-documented and field-tested.

### References and citations

Every reference must be followable. A reader who cannot reach what you cited cannot check the claim you made with it.

**Never write the section symbol (`§`).** It names no document and resolves to no location, so it sends the reader hunting. Write the reference instead:

| Context | Instead of | Write |
| --- | --- | --- |
| Prose, where a link renders | `§8` | `[technical plan, PostgreSQL and Hyperdrive](../technical-plan.md#8-postgresql-and-hyperdrive)` |
| Code comments and strings, where links do not render | `§8` | `technical-plan.md section 8` |
| Within one document | `§3` | `[command surface](#3-command-surface)` |
| Chat replies and reviews | `§5` | the section's name, and its link when you have one |

The rule covers every citation shorthand, not only the symbol: `ibid.`, `op. cit.`, "see above", "as mentioned earlier", and a bare page, line, or clause number all fail the same test. Name the target, then link to it wherever the medium allows.

## Technical documents

Apply this part on top of [Prose](#prose) when writing a document or a diagram. Skip it for chat replies, commit subject lines, and UI copy.

A doc succeeds when its audience can make a decision or complete a task without asking you a follow-up question.

Distilled from [Google's technical writing courses](https://developers.google.com/tech-writing/overview). Follow the links when a rule needs its worked examples.

### 1. Decide the audience before the first sentence

- Name the reader and what they already know. Everything obvious to you is invisible to them — the curse of knowledge is the top cause of unusable docs. ([audience](https://developers.google.com/tech-writing/one/audience))
- Write the goal in one sentence: after reading this, the reader can **X**.
- State scope **and** out-of-scope explicitly. Out-of-scope prevents more review churn than any other section. ([documents](https://developers.google.com/tech-writing/one/documents))
- Put the key point first — title and opening paragraph should carry the takeaway alone.

### 2. Words and sentences

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

### 3. Diagrams

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

### 4. Self-edit before anyone else reads it

Do this pass every time — it is where the quality comes from. ([self-editing](https://developers.google.com/tech-writing/two/editing))

1. Step away, then reread as the audience you named in step 1.
2. Cut 10% of the words. There is always 10%.
3. Skim test: read only headings and first sentences. Does the argument still stand?
4. Verify every claim, link, command, and code sample. Run the samples.
5. Ask someone outside the team where they got confused, and fix that spot — not the sentence you were proud of.

### Checklist

- [ ] Audience and goal named; scope and out-of-scope stated
- [ ] Takeaway in the title and first paragraph
- [ ] Terms defined once and used consistently
- [ ] Active voice, one idea per sentence, no filler
- [ ] Steps as numbered lists; comparisons as tables
- [ ] Each diagram carries one message and a caption; readable in grayscale
- [ ] Samples run; links resolve
- [ ] Cut 10% and passed the skim test

### Common mistakes

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

## Bottom line

Writing for humans? Load the relevant section from `elements-of-style/` and apply the rules. For most tasks, `03-elementary-principles-of-composition.md` covers what matters most. Writing a document? Name the audience first and self-edit last. Whatever you cite, cite it so the reader can follow it.
