# Web quality: what the baseline leaves out

`baseline-ui.md`, `accessibility.md`, and `motion-performance.md` cover styling, ARIA, and animation. This file adds the web rules they do not have: WCAG 2.2, measured contrast, loading and interaction performance, interaction behaviour, internationalisation, and browsers. Apply the sections that match the change. Skip the whole file for React Native and native apps; `ios-native.md` and `android-native.md` cover those.

The repo's stack wins. If the repo does not use Tailwind, skip the Stack section of `baseline-ui.md` and its Tailwind class names, and apply the rule behind each one with the repo's own styling.

Sources: [What's New in WCAG 2.2](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/) · [Front-End Checklist](https://github.com/thedaviddias/front-end-checklist) · [Vercel Web Interface Guidelines](https://vercel.com/design/guidelines) · [web.dev Core Web Vitals](https://web.dev/articles/vitals)

## 1. Accessibility beyond ARIA

- [ ] **Target size.** Every pointer target is at least 24 × 24 CSS px, or has enough spacing that a 24px circle on it overlaps no other target (WCAG 2.5.8). On touch layouts use 44 × 44. Extend the hit area with padding when the glyph is smaller.
- [ ] **Focus not obscured.** Tab through the page with every sticky element present (header, footer, cookie banner, chat launcher). The focused element is never fully hidden under one (WCAG 2.4.11). Fix with `scroll-padding` or `scroll-margin`.
- [ ] **Dragging has an alternative.** Anything done by dragging (reorder, slider, resize, map pan) can also be done with single clicks or taps (WCAG 2.5.7).
- [ ] **Accessible authentication.** Login and one-time-code fields accept paste and password managers, with correct `autocomplete` values. No step requires transcribing or remembering a code without an alternative (WCAG 3.3.8).
- [ ] **No redundant entry.** A multi-step flow does not ask again for information already given in the same flow; it pre-fills or offers it for selection (WCAG 3.3.7).
- [ ] **Consistent help.** If help or contact appears on several pages, it sits in the same relative place on each (WCAG 3.2.6).
- [ ] **Reflow.** At 320 CSS px wide (the same as 400% zoom on a 1280px window) the content is one column, with no horizontal scroll and nothing clipped (WCAG 1.4.10).
- [ ] **Text resize.** At 200% text size nothing clips, overlaps, or loses function (WCAG 1.4.4).
- [ ] **Zoom is not disabled.** The viewport meta has no `user-scalable=no` and no `maximum-scale` below 2.
- [ ] **Orientation.** Content and function work in portrait and landscape unless one orientation is essential (WCAG 1.3.4).
- [ ] **Contrast, measured.** Text is at least 4.5:1, or 3:1 at 24px and above (18.66px bold). Input borders, icons, and focus indicators are at least 3:1 against what is next to them (WCAG 1.4.11). Check each state: default, hover, focus, disabled text that still carries meaning. Measure with:

  ```sh
  bash <skill-dir>/scripts/contrast.sh '#6b7280' '#ffffff'
  ```

- [ ] **Automated check.** If the repo already has axe (`jest-axe`, `@axe-core/playwright`, a Storybook accessibility addon), run it on the changed surface and fix what it reports. It finds roughly the mechanical third of problems; the rest of this list still applies. Do not add the dependency without asking.
- [ ] **Keyboard pass, performed.** Tab through the changed surface from top to bottom: every control is reachable, focus is visible, the order follows the layout, Escape closes overlays, and focus returns to the trigger.

## 2. Performance of the changed surface

Check what the change can affect. Do not start a site-wide performance audit.

- [ ] **No layout shift.** Images, video, embeds, and ads have `width` and `height` or an `aspect-ratio`. Content loaded later does not push existing content down; reserve its space or use a skeleton of the final size. Target CLS under 0.1.
- [ ] **Interaction is fast.** A click or key press produces visible feedback within 200ms (INP). Move heavy work out of the event handler, show the pending state first, and debounce or throttle scroll, resize, and input handlers.
- [ ] **Largest element loads first.** The hero image or heading is not lazy-loaded, and the hero image has `fetchpriority="high"` or the framework's priority flag. Target LCP under 2.5s.
- [ ] **Below-the-fold media is lazy.** `loading="lazy"` on images and iframes that start off screen.
- [ ] **Images are sized for their slot.** Responsive `srcset` and `sizes`, a modern format where the pipeline supports it, and no multi-megabyte image in a small box.
- [ ] **Long lists are virtualised** once the row count can grow into the hundreds.
- [ ] **Fonts do not block or shift text.** `font-display: swap` or `optional`, and preload only the faces used above the fold.
- [ ] **Heavy code loads on demand.** A modal, editor, chart, or map that opens on interaction is imported on that interaction, not on first render.

## 3. Interaction behaviour

- [ ] **State lives in the URL.** Filters, tabs, pagination, sort order, and open detail panels survive refresh, share, and Back and Forward.
- [ ] **Back restores the page.** Scroll position and list state return on Back.
- [ ] **Links are links.** Navigation uses `<a>` (or the router's link), so open-in-new-tab, middle click, and copy link work. Buttons are for actions.
- [ ] **Optimistic updates roll back.** When the UI updates before the server answers, a failure shows an error and restores the previous state, or offers Undo.
- [ ] **Submit is safe to repeat.** A second click or Enter while a request is pending does not send it twice. The button shows a pending state and keeps its width and label.
- [ ] **Forms.** Enter submits. Submit is not disabled before the user has tried; validate on submit and show each error next to its field, with focus on the first one. Typing and paste are never blocked. Input values and focus survive hydration.
- [ ] **Mobile inputs.** Input text is at least 16px so iOS Safari does not zoom on focus. `inputmode`, `type`, and `autocomplete` match the field.
- [ ] **Every async state is designed.** Loading, empty, error with a retry, and partial data each have a visible state. A spinner that can spin forever is a defect; add a timeout path.
- [ ] **Destructive actions** ask for confirmation or offer Undo.

## 4. Internationalisation and right-to-left

Apply when the product ships in more than one locale, or will.

- [ ] Strings come from the locale files. No sentence is built by joining fragments; use placeholders and plural rules.
- [ ] Layout uses logical properties (`margin-inline`, `padding-inline`, `inset-inline`, `text-align: start`), so it mirrors under `dir="rtl"`. Directional icons (back, next, chevrons) mirror; logos, media controls, and numbers do not.
- [ ] The layout holds text that is 30 to 40% longer than English, and a single long word.
- [ ] Dates, numbers, currency, and relative times use `Intl` with the user's locale, not hand-built formats.
- [ ] `<html lang>` is set, and `dir` where the locale needs it.
- [ ] If the repo supports a right-to-left locale, capture the changed screen in it and check it against the stress rules in `compare.md` §5.

## 5. Browsers and input types

- [ ] The changed surface is checked in a Chromium browser and in Safari. Add Firefox when the repo's support list includes it. Layout features that differ most: `dvh` units, `position: sticky` inside overflow containers, `gap` in older Safari, date inputs, and scrollbar width.
- [ ] iOS Safari, on a phone or the Simulator: the bottom toolbar does not cover fixed actions (use `dvh` and `env(safe-area-inset-bottom)`), and the keyboard does not hide the focused field.
- [ ] Hover-only affordances have a touch and a keyboard equivalent.
- [ ] If a browser cannot be run, list it under "Not checked".
