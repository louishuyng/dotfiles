---
name: code-as-designer
description: Code like the designer would. Implement a frontend or mobile UI ticket so it matches its Figma design exactly. It reads Figma through the Figma MCP server, or through the signed-in browser via aside when MCP is missing or rate-limited, and builds on the repo's foundation tokens and core/shared components. It stops when a design token is missing or drifted. It checks text content, case, font, weight, size, spacing, and layout; checks iPhone native behaviour and transitions; tests on a real iPhone with a mocked backend; organizes per-feature Storybook stories as an ordered flow; and ends with a local Figma-vs-implementation report plus a PR description carrying high-resolution side-by-side screenshots (and videos for behaviour), hosted as GitHub attachments and never committed. Use when a ticket or request includes a Figma link, or asks to build, fix, or polish a screen, component, or flow "to match the design", especially React Native / Expo / iOS work.
---

# Code as designer

The goal is to ship UI that a designer can't tell apart from the Figma frame, built only from the repo's tokens and components, and that feels native on iPhone. Every claim must have evidence.

This skill covers fidelity to a specific design. General UI quality comes from three skills it inherits, plus the `ui-frontend` hook.

## Inherited skills

Read these before step 4 and apply them while building. Check them again in step 7.

| Skill | Applies to | On React Native / native iOS |
| --- | --- | --- |
| `baseline-ui` | Every screen and component | Apply the stack-neutral rules: accessible primitives, labelled icon-only buttons, a confirmation for destructive actions, errors next to the action, safe areas, one clear next action in empty states. Skip the Tailwind and CSS rules. |
| `fixing-accessibility` | Every interactive control, form, and dialog | Same rules through `accessibilityLabel`, `accessibilityRole`, and `accessibilityState`. `ios-native.md` covers VoiceOver and Dynamic Type. |
| `fixing-motion-performance` | Any animation or transition | The equivalent rule is motion on the UI thread; see `ios-native.md`. |

Order of precedence:

1. Figma and the repo's tokens decide every visual value. A skill's style default (no gradients, no letter-spacing changes, default shadows, no animation unless requested) never overrides a value the design specifies.
2. The inherited skills decide what the design leaves open: semantics, keyboard and focus behaviour, loading, empty and error states, and how motion is implemented.
3. If the design itself breaks an accessibility rule, such as low contrast, a touch target under 44pt, or no focus state, build it as designed only after you raise it. List it in the report as a design finding. Do not fix it silently and do not ignore it.

## References (load when the step needs them)

| File | When |
| --- | --- |
| `references/figma-access.md` | Step 2: MCP tools, limits, aside/REST fallback |
| `references/fidelity.md` | Steps 1, 3, 4: design-system map, **token gate**, text/layout checks |
| `references/ios-native.md` | Steps 4–5: any iOS / React Native screen |
| `references/real-device.md` | Step 5: physical iPhone, mocking the backend |
| `references/storybook.md` | Step 6: only if the repo has Storybook |
| `references/report.md` | Steps 7–8: report layout, PR screenshots/videos, keeping evidence out of git |

## Hard rules

- **No guessed values.** Every color, size, spacing, radius, font, and string traces to a Figma node and a repo token or component. If Figma can't be read, stop and ask. See `figma-access.md` "When nothing works".
- **Token gate.** A missing token, a drifted token, or an unmatched raw value means STOP before UI code. Show the token table and ask whether to sync the token from Figma. Never hardcode to get past the gate. See `fidelity.md` §2.
- **Components before markup.** Use Code Connect snippets and core/shared components. A missing variant is a proposal to change the core component, not a local copy.
- **Nothing visual in git, everything visual in the PR.** Screenshots, recordings, diffs, and reports go to `.ui-review/` (excluded via `.git/info/exclude`). The PR description shows Figma-vs-implementation screenshots, and videos for any behaviour, uploaded as GitHub attachments. See `report.md` "PR evidence".
- **The repo's conventions win** over this skill's defaults. Follow its token naming, Storybook titles, i18n, and test setup.
- **A backend gap never blocks UI verification.** Use the repo's mocks or fixtures. Mock code never reaches production.

## Workflow

Track these as tasks. One step is in progress at a time.

### 1. Scope and map

- Read the ticket and acceptance criteria. Collect every Figma link: screens, states, flows, dark variants, and the prototype.
- List the frames you will implement, in flow order. Ask if the design is missing a state the ticket needs, such as error or empty.
- Map the design system and write `.ui-review/design-map.md`, as in `fidelity.md` §1.
- Detect the platform and stack: RN/Expo, SwiftUI, or web. Check whether Storybook exists, which mock layer the repo uses, and the test commands.
- Set up `.ui-review/` and the git exclude (see `report.md`).

### 2. Read Figma

- Prefer MCP, in this order: `get_metadata`, then `get_design_context` per section, `get_variable_defs`, `get_screenshot`. Check `get_code_connect_map` for components. Cache everything in `.ui-review/figma/`.
- If MCP is missing, rate-limited, or truncated, use aside (Dev Mode Inspect + export) and then REST with the user's token. Record which source you used.

### 3. Token and component gate

- Classify every value per `fidelity.md` §2. Map every Figma component to a repo component.
- If anything is DRIFT, MISSING, an unmatched raw value, or a missing component variant: **stop**. Show the table and ask the user to choose between syncing from Figma, treating it as a design error, or using the closest token with a note.
- Do a token sync only when the user approves it. Do it as its own step: use the repo's token tooling if it has any, check for any usages the change affects, and keep the commit separate.

### 4. Build

- Build the smallest complete change from tokens and components, following the repo's patterns for screens, navigation, and data.
- Work through `fidelity.md` §4 (text), §5 (layout), and §6 (behaviour) node by node.
- For iOS, follow `ios-native.md`: native stack, swipe-back, sheets, keyboard, haptics, motion on the UI thread, accessibility, and dark mode.
- Wire the data states (loading, empty, error, long text) to the repo's mock fixtures.
- Apply the inherited skills to what the design leaves open (see "Inherited skills").
- Run the repo's lint, typecheck, and tests for the touched area.

### 5. Verify on device

- Simulator: work through the device matrix (SE, frame width, Pro Max), light and dark, default type size and AX5, VoiceOver, and Reduce Motion.
- Physical iPhone (`real-device.md`): release build, mock mode on. Test motion and gestures, haptics, keyboard and autofill, and performance. Record swipe-back, sheet dismiss, and large-title collapse into `.ui-review/device/`.
- If the device or signing needs the human, ask for that single action. If it can't be done, list it under "Not checked". Never claim it passed.

### 6. Storybook (if present)

- Organize stories per `storybook.md`: Foundations, then Core/Shared, then `Features/<Feature>/<n>. Step` in Figma flow order, with states in a fixed order. Link each story to its Figma frame and feed it from the shared fixtures.
- Check that the sidebar order matches the flow, every step has a story, and Storybook loads with no errors.

### 7. Compare and report

- Capture each story or screen at the Figma frame size and scale into `.ui-review/impl/`.
- Build `.ui-review/report.html` (`report.md`). It holds the side-by-side views plus the token table, text audit, native behaviour results, Storybook tree, assumptions, and a "Not checked" list.
- Review the changed files against the inherited skills. Fix violations, and list design findings in the report.
- Fix the mismatches you can fix. Re-capture, and repeat until only accepted deviations remain.
- Open the report, then give the human its absolute path and a short summary of what matches, what deviates and why, and any open decisions.

### 8. PR evidence

- Export PR images and videos per `report.md` "PR evidence": @3x PNG, one phone per cell, Figma and implementation side by side at the same size.
- Record a short video for every behaviour a still can't show: transitions, gestures, sheets, keyboard, loading-to-content.
- Upload them as GitHub attachments in the PR description, never as repo files. Size each image with `<img width>` so it's readable without zooming and two fit side by side.
- If uploading needs the human (no browser session, no PR yet), hand them the exact files from `.ui-review/pr/` and the ready-to-paste body.

## Done means

- Every implemented frame has a side-by-side row with no unexplained deviation.
- The token gate is clean, or the human made a decision on each item.
- Text audit: every string matches in content, case, style, weight, and size.
- iOS checklist: passed on the simulator matrix and on a physical iPhone, or each skipped item is listed with its reason.
- The inherited skills report no open violation, and each design finding is in the report.
- Storybook (if present) mirrors the flow in order.
- Lint, typecheck, and tests pass. `git status` shows no images, videos, or `.ui-review/`.
- The PR description has a side-by-side screenshot row for every frame and a video for every changed behaviour, all as GitHub attachments that render at a readable size.
- PR creation follows the repo's or user's ship workflow. This skill never pushes on its own.
