# Storybook as a feature story

Only when the repo already has Storybook. Read its config first (`.storybook/` web, `.rnstorybook/` or `.storybook/` RN), the existing feature folders, and `storySort`. **The repo's convention wins over this file**; these rules fill gaps and get applied the same way the neighbours do it.

Sources: [naming & hierarchy](https://storybook.js.org/docs/writing-stories/naming-components-and-hierarchy) · [play function](https://storybook.js.org/docs/writing-stories/play-function) · [viewport](https://storybook.js.org/docs/essentials/viewport) · [addon-designs](https://github.com/storybookjs/addon-designs) · [RN Storybook](https://github.com/storybookjs/react-native) · [test-runner](https://storybook.js.org/docs/writing-tests/integrations/test-runner)

## Organization: the sidebar reads like the flow

- One folder per feature, e.g. `src/features/checkout/` with its stories beside the components (or the repo's `stories/` dir).
- Layers stay separate: `Foundations/*` (tokens), `Core/*` / `Shared/*` (design-system components), `Features/<Feature>/*`. A feature story never re-implements a core component; if one is missing it's a finding, not a local copy.
- Flow steps are numbered in the title so order never depends on alphabet: `Features/Checkout/0. Overview` (MDX), `1. Cart`, `2. Address`, `3. Payment`, `4. Confirmation`. Pad to `01.` past nine steps. Numbers match the Figma flow's frame order.
- Pin the order in `.storybook/preview` too (web):
  ```ts
  parameters: { options: { storySort: { order: ['Foundations', 'Core', 'Shared', 'Features', ['Checkout', ['0. Overview', '1. Cart', '2. Address', '3. Payment', '4. Confirmation'], '*'], '*'] } } }
  ```
  `'*'` places unlisted items; nested arrays order the children of the item before them. RN on-device `storySort` support is unverified: rely on numbered titles + export order there.
- Inside a step file, export states in a fixed order (export order = sidebar order): `Default`, `Loading`, `Empty`, `Error`, `LongText`, `LargeText` (RN fontScale / web zoom), `Dark`, `Disabled`/edge cases that the design has. Only states the design or ticket defines, plus long-text and large-text.
- Export names are stable (they form the story id used for screenshot filenames); use `name:` for display labels.
- A feature overview MDX (`<Meta title="Features/Checkout/0. Overview" />`) tells the story: what the feature does, the step list linking each step, the Figma link.

## Each story

- `parameters.design = { type: 'figma', url: '<exact frame URL with node-id>' }` when `@storybook/addon-designs` is installed; otherwise put the Figma URL in the story's `parameters.docs.description`. A story with no frame is reported as "no design reference".
- Viewport matches the Figma frame (web: `globals: { viewport: { value: 'iphone14pro' } }` in SB9+, or a custom entry for 402/440 widths; RN: pick the simulator model).
- Data from the same typed fixtures the app's mock mode uses (`real-device.md`). Fixed dates, seeded data, animations off in capture mode.
- Flows (web): a `play` with `step('Add item', …)` per user action; a `Full flow` story chains step plays (`await Cart.play?.(ctx)`). RN on-device has no play/interactions panel — cover the flow on device instead.

## Capturing for the comparison report (never committed)

All output goes to `.ui-review/` — add it to `.git/info/exclude` (local, no repo change) before the first capture.

- Web: `storybook build -o .ui-review/sb`, serve it, then Playwright or `test-storybook` with a `postVisit` screenshot to `.ui-review/impl/<story-id>.png` at the Figma frame size and scale.
- RN: boot the matching simulator, open the story (`initialSelection` or the websocket), `xcrun simctl io booted screenshot .ui-review/impl/<story-id>.png`. Device: see `real-device.md`.
- If capture tooling would need a new dependency, ask first; a manual screenshot per story is acceptable.

## Review checklist

- [ ] Sidebar order equals Figma flow order; no step out of sequence, no duplicate numbering.
- [ ] Every feature step has a story; every story maps to one Figma frame.
- [ ] Feature stories compose core/shared components; no copied styles.
- [ ] States in the fixed order; long-text and large-text present.
- [ ] Storybook builds/loads with no console errors; existing stories still render.
