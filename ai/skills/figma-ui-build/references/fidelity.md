# Fidelity: tokens, components, text, layout

## 1. Map the design system before writing UI

Find what exists. Search; don't assume:

- **Foundations / tokens:** theme files, `tokens.json`, Style Dictionary output, Tailwind config, `theme.ts`, `colors.ts`, `typography.ts`, `spacing.ts`, CSS variables, NativeWind/Tamagui/Restyle/unistyles config.
- **Core components:** primitives such as Button, Text/Typography, Icon, Input, Stack/Box.
- **Shared components:** composed pieces such as cards, list rows, headers, sheets, empty states.
- **Code Connect:** `*.figma.tsx` / `figma.config.json` link Figma components to code.

Write a short map to `.ui-review/design-map.md`: the token source file, naming scheme, core/shared component paths, and how text styles are applied. Every later decision cites this map.

## 2. Token gate (stop condition)

For every value in the Figma nodes you implement (color, spacing, radius, typography, shadow, opacity, size), classify it:

| Case | Action |
| --- | --- |
| Figma variable → repo token exists, same value | Use the token. |
| Figma variable → repo token exists, **different value** | **STOP.** Token drift. |
| Figma variable → **no repo token** | **STOP.** New token needed. |
| Raw Figma value equals an existing token's value | Use the token. Note in the report that the design detached it. |
| Raw Figma value, no token matches | **STOP.** Ask whether it is a new token or a design mistake. |
| Value is a platform default (safe area, native bar heights) | Use the platform value. Don't tokenize it. |

When you STOP, before writing UI code, give the user a token table:

```
Token check — <frame name> (<figma url>)
| Figma variable / raw   | Figma value | Repo token        | Repo value | Status   |
| color/brand/600        | #1F6FEB     | colors.brand[600] | #2563EB    | DRIFT    |
| spacing/xl             | 28          | —                 | —          | MISSING  |
| raw #F4F4F5 (card bg)  | #F4F4F5     | colors.gray[100]  | #F4F4F5    | DETACHED |
Need decision: sync new tokens from Figma, or treat as design error?
```

Then wait. Never hardcode a literal to "match for now". Never edit token values silently. A token sync is a design-system change, done in its own step and in its own commit, using the repo's sync tooling if it has any.

## 3. Components

- Code Connect snippet or an existing core/shared component → use it with the props the design shows. Map Figma variant properties to component props.
- The design shows a variant the component lacks → STOP and propose adding the variant to the core component (one place), not a local override.
- A genuinely new feature-only component is built **from** core primitives and tokens. No raw `View`/`div` styling that duplicates a primitive.
- No inline style literals for themed values. Layout-only values (flex, alignment) are fine.

## 4. Text: check every string node

For each text node, compare Figma with the implementation:

- [ ] **Content:** exact string. Same punctuation, apostrophe style (’ vs '), ellipsis (… vs ...), spaces, numbers and units format. Copy it from Figma; don't retype.
- [ ] **Case:** what Figma *renders*. If Figma uses a text-case property (UPPER/Title/lower), apply it via the style's `textTransform`. Otherwise, use the string as written. Don't "fix" capitalization. If copy looks wrong, flag it.
- [ ] **i18n:** if the repo uses i18n, the string goes in the locale file under the repo's key convention, not inline. Add other locales per repo rule, or flag them as missing.
- [ ] **Style:** uses the matching text style token (e.g. `Text variant="bodyMedium"`), not ad-hoc size/weight.
- [ ] **Family + weight:** the exact face. On iOS RN, weight comes from the font file per weight (see `ios-native.md` §3). Verify on a render, not in code.
- [ ] **Size / line height / letter spacing:**
  - Figma px = pt (1x frame).
  - Line height `auto` means the font default. Don't hardcode one.
  - Letter spacing `%` → `size × % / 100`.
- [ ] **Color** via token. **Alignment**, **max lines / truncation** as the design shows, with long-text behaviour defined.
- [ ] Dynamic values (names, prices, dates) are formatted the way the design's sample shows: locale, currency, date pattern.

## 5. Layout and spacing

- [ ] Auto-layout → flex. Direction, `gap` = item spacing, padding per side, alignment (primary/counter axis), wrap.
- [ ] Sizing: Hug = intrinsic, Fill = `flex: 1` / stretch, Fixed = token size. Don't hardcode widths the design meant as Fill.
- [ ] Constraints and min/max widths respected. The layout holds at SE width (375) and Pro Max (440), not only the frame width.
- [ ] Radius, border width, border color, shadow (iOS shadow props), and opacity are all from tokens.
- [ ] Icon size and its box, image aspect ratio and `resizeMode`/`object-fit` match.
- [ ] Spacing between sections matches. Measure from the Figma outline (`get_metadata` positions), not by eye.
- [ ] Safe area and native bars come from the platform, not the frame's mock status bar.

## 6. Behaviour from the design

- [ ] Every interactive state the design defines: pressed, disabled, focused, selected, error, loading, empty.
- [ ] Prototype transitions (`get_motion_context` or prototype panel) are matched: type, duration, easing/spring.
- [ ] Anything the design does not specify follows platform defaults (`ios-native.md`). List those assumptions in the report.
