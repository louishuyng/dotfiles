# Compare gate: prove the implementation matches the design

Looking at two full-screen screenshots and saying "matches" is how differences get missed. A 4pt offset, a wrong radius, or a weight one step off is invisible at that zoom. This gate replaces the glance with checks that each produce evidence: measured padding and text styles, a pixel diff that points at regions, a stress matrix for long content and small devices, behaviour checks that are performed, and a reviewer who has not seen the code.

Run it after the first section is built, and again for every frame before you report. Never tell the human a screen matches without the output of §3 for that screen.

## 1. Spec sheet: numbers before pixels

Before building a frame, write `.ui-review/spec/<frame>.md` from the Figma data (`get_metadata` positions, `get_design_context`, `get_variable_defs`). One row per node you implement:

```
| Node            | x   | y   | w   | h  | Font / size / weight / line height | Colour token   | Radius | Gap / padding |
| Header title    | 16  | 62  | 240 | 34 | SF Pro 28 / 700 / 34               | text.primary   | —      | —             |
| Pay button      | 16  | 742 | 370 | 52 | SF Pro 17 / 600 / 22               | brand.600      | 14     | pad 16        |
```

Units are points at 1x, relative to the frame. This sheet is what the implementation is checked against. A value that is not in the sheet has not been read from Figma, so read it; do not estimate it from the screenshot.

## 2. Capture both sides the same way

- Same width and scale. An iPhone frame 402pt wide is 1206px at @3x on both sides. `compare.sh` refuses different widths; fix the capture, never resize an image to make it pass.
- Same data. Fixture strings equal the Figma sample text, so every difference is a real one.
- Same mode and state: light or dark, default type size, the same scroll position.
- Status bar: normalise the Simulator (`real-device.md`) or drop it from both sides with `--crop-top`.
- Android: densities are often not whole numbers, so export the Figma frame at the device's exact pixel width (`android-native.md` §10).
- Save to `.ui-review/figma/<frame>.png` and `.ui-review/impl/<frame>.png`.

**Make the capture repeatable.** A diff is only useful if the same screen captures the same way twice.

- Freeze motion. Web: capture with animations disabled and the caret hidden (Playwright `animations: 'disabled'`, `caret: 'hide'`). iOS and Android: there is no tool that pauses a native app's animations for you, so capture after they finish, and turn off looping animations, auto-advancing carousels, and shimmer in the app's mock or capture mode. On Android also set the three animation scales to 0 (`android-native.md` §10).
- Wait until the screen has settled: fonts loaded (web: `document.fonts.ready`), images decoded, skeletons gone, no request pending.
- Pin what changes between runs: the clock and dates (a fixed "now" in the fixture), random or generated ids, and remote images (use local fixture images).
- Close the keyboard and hide scroll indicators, unless the state being captured is the keyboard.
- **Stability check:** capture the implementation twice and run `compare.sh` on the two captures. Every band must be `ok`. If not, the capture is unstable; fix that before comparing with Figma, or every later diff is noise.

## 3. Pixel diff by band

```sh
bash <skill-dir>/scripts/compare.sh .ui-review/figma/<frame>.png .ui-review/impl/<frame>.png .ui-review/diff/<frame>
```

The script needs ImageMagick 7. It scores each horizontal band and writes a `band-NN.png` strip (Figma, implementation, diff) for every band over the threshold. If ImageMagick is missing, say so and list the pixel diff under "Not checked"; do not replace it with a glance.

For each band marked `LOOK`:

1. Open the strip. It is a crop at full resolution, so small offsets are visible.
2. Name the node and the property that differs: position, size, radius, weight, colour, missing element.
3. Measure the difference in pixels on both sides and convert to points (px / scale). Compare it with the spec sheet row.
4. Add a row to the ledger (§7).

A band marked `ok` still needs the text audit (`fidelity.md` §4): a wrong word of the same length can stay under the threshold.

Defaults: 12 bands, 0.5% threshold, 6% colour fuzz. Fonts and anti-aliasing produce noise under that level. Raise `--bands` for long screens. Do not raise the threshold or the fuzz to get a pass; an accepted difference goes in the ledger instead.

## 4. Measure padding and text

The pixel diff says where something differs. It does not say which property is wrong, and it misses a wrong weight or colour that changes few pixels. So check these two tables against the spec sheet for every frame, from resolved values, not from reading the source and assuming.

**Box, per container and control**

| Check | Tolerance |
| --- | --- |
| Padding on each side (top, right, bottom, left), separately | exact |
| Gap between siblings, and space between sections | exact |
| Width and height, or the sizing mode (hug, fill, fixed) | 1pt |
| Position relative to the parent | 1pt |
| Radius, border width, border colour | exact |

**Text, per text node**

| Check | Tolerance |
| --- | --- |
| Font family and the exact face | exact |
| Size | exact |
| Weight | exact |
| Line height and letter spacing | exact |
| Colour, as the token and as the rendered value | exact |
| Content, case, alignment, max lines | exact |

How to get resolved values:

- **Web:** in the browser, read `getComputedStyle()` (padding, gap, font-family, font-size, font-weight, line-height, color) and `getBoundingClientRect()` for each spec row.
- **React Native:** if the repo has Jest with React Native Testing Library, render the screen with the fixture and assert the resolved style of each spec row with `toHaveStyle`. This checks the values after tokens and variants resolve. Use the repo's existing test setup; do not add a test dependency without asking.
- **Android:** `adb shell uiautomator dump` gives every element's bounds in pixels. Divide by the density to get dp and compare with the spec sheet (`android-native.md` §10).
- **Any platform, from the screenshot:** measure padding and gaps in pixels and divide by the scale. Sample a rendered colour with `magick <image> -depth 8 -format '%[hex:u.p{X,Y}]' info:` at a pixel inside the text stroke or the fill.
- **Font face and weight** cannot be read from pixels. Assert the resolved style, confirm the font file for that weight is loaded (`ios-native.md` §3), then compare the glyph shapes in a zoomed strip.

**Contrast.** For each text colour and its background, and each icon or input border and its neighbour, run `bash <skill-dir>/scripts/contrast.sh <foreground> <background>`. Text needs 4.5:1 (3:1 when large); icons, borders, and focus indicators need 3:1. A design value that fails is a design finding: raise it, do not change it silently.

Record the result as a table in `.ui-review/spec/<frame>.md`: each spec row with the Figma value, the measured value, and pass or fail. Every fail is a ledger row.

## 5. Stress matrix: content and devices the frame does not show

A Figma frame shows one device width and short sample text. Most real defects are outside it. There is no reference image for these cases, so the check is a set of rules, each with a capture in `.ui-review/stress/`.

Run each screen through:

| Case | How |
| --- | --- |
| Smallest supported device | iPhone SE (375 x 667pt) and a 360dp-wide Android phone, or the smallest in the repo's support list. On web, 320px wide. |
| Frame width | The width the design was drawn at. |
| Largest device | Pro Max (440pt wide) and a 412dp-wide Android phone. On web, the widest breakpoint. |
| Tablet and landscape | Only if the app supports them: iPad or a 600dp-wide Android device, and each phone rotated. |
| Long content | A fixture with long names, long titles, a long translated string (German or similar), large numbers and prices, and a list with many items. |
| Minimal content | Empty, and exactly one item. |
| Large text | Dynamic Type at AX5 on iOS (`xcrun simctl ui booted content_size accessibility-extra-extra-extra-large`); the largest font size on Android; 200% text size on web. |
| Right-to-left | Only if the product ships a right-to-left locale: the screen in that locale. Layout mirrors, directional icons flip, nothing overlaps. |
| Dark mode | Every case above that the design defines in dark (`xcrun simctl ui booted appearance dark`). |
| Android navigation mode | Gesture navigation and three-button navigation. |
| Keyboard open | On the smallest device, with the last field focused. |

Rules that must hold in every case:

- No text is clipped or overlaps another element. Truncation happens only where the design specifies it, with the specified max lines.
- No element leaves the screen horizontally. Nothing important sits under the notch, the home indicator, or the keyboard.
- Padding to the screen edge and the gaps between elements stay at the spec value. A layout that keeps its padding by squeezing a tap target under 44pt fails.
- Content taller than the screen scrolls, and the last item and the primary action are reachable.
- Fixed footers and primary buttons stay visible and do not cover the content they belong to.
- Images keep their aspect ratio.

Each case gets a row in the report with its capture and pass or fail. A case you did not run is listed under "Not checked".

## 6. Behaviour: check by doing, not by looking

A screenshot cannot show what happens on a tap, a scroll, or a keyboard. List the behaviours of the screen from the design, the prototype, and the ticket, then perform each one. `ios-native.md` §4 to §8 lists the native ones.

Typical rows:

| Behaviour | Expected | Evidence |
| --- | --- | --- |
| Press state of each control | Feedback appears on press and reverts on release | recording frames |
| Disabled and loading states | Control does not fire; loading indicator replaces the label | test output |
| Navigation push, back, swipe-back | Correct screen, correct transition, state kept on return | recording frames |
| Scroll | Header collapses or stays as designed; bounce; content not hidden under bars | recording frames |
| Keyboard | Focused field stays visible; return key moves to the next field or submits; tap outside dismisses as designed | recording frames |
| Sheet or modal | Opens, drags, dismisses, and returns focus | recording frames |
| Form validation | Error text appears next to the field at the right moment and clears on fix | test output |
| Pull to refresh, pagination, empty to content | Each state transition happens with the right indicator | test output or frames |
| Double tap on submit | One request is sent; the control shows a pending state | test output |
| Offline and slow network | The designed error or offline state appears with a retry; nothing spins forever; retry works when the network returns | frames or test output |
| Request fails (500) | Error state next to the action; entered data is kept | test output |
| Permission denied (camera, photos, location, notifications) | The designed fallback appears, with a way to open Settings | frames |
| Background, then return | The screen, scroll position, and entered text are kept; data refreshes if the design says so | frames |
| Deep link into the screen, then back | The right screen and state open; back goes to the logical parent, not out of the app | frames |
| Rotation, if supported | Layout adapts; state and scroll position are kept | frames |
| Android system back | Closes keyboard, then overlay, then screen, in that order (`android-native.md` §4) | frames |
| Android activity destroyed in background | Returning restores the screen and its input (`always_finish_activities`) | frames |

Drop a row only when the screen cannot be in that situation, and say so.

How to perform them, in order of preference:

1. **The repo's UI test runner** (Maestro, Detox, XCUITest, Playwright). Write or run a flow that performs the action and asserts the result. Do not add a runner without asking.
2. **`adb` on Android.** With no runner, drive the device directly: `adb shell input tap`, `swipe`, `text`, and `keyevent`, plus the offline, deep link, and background commands in `android-native.md` §10. Capture after each step.
3. **Component interaction tests** with the repo's test library (`fireEvent`, `userEvent`): press, type, submit, and assert the state and the callbacks. This covers logic, not gestures or animation.
4. **A recording you have read.** Record the action (`xcrun simctl io booted recordVideo`), extract frames with `ffmpeg -i clip.mp4 -vf fps=10 frames/%03d.png`, and look at the frames around the action. A recording you did not open is not evidence.
5. **The human.** If the action needs a physical gesture or a device you cannot drive, give them the exact steps and the expected result, one line each, and wait for their answer. Mark the row "Not checked" until then.

Never mark a behaviour as passing because the code looks right.

## 7. Mismatch ledger

Keep `.ui-review/ledger.md`. One row per difference found by any check. Nothing is fixed or dismissed without a row.

```
| # | Frame / check   | Node         | Property    | Figma | Implementation | Cause                    | Status           |
| 1 | Cart / band 02  | Summary card | padding-top | 16pt  | 20pt           | extra marginTop on title | fixed, round 2   |
| 2 | Cart / band 02  | Summary card | radius      | 16    | 12             | token radius.lg drift    | waiting on human |
| 3 | Cart / text     | Price        | weight      | 600   | 500            | wrong text variant       | open             |
| 4 | Cart / SE width | Pay button   | clipped     | —     | label cut off  | fixed width on the label | open             |
```

Status is one of: `open`, `fixed, round N`, `waiting on human`, `accepted by human: <reason>`. Only the human accepts a deviation. A platform difference you believe is correct (native bar height, safe area) is still listed and explained.

## 8. Loop

1. Fix every `open` row.
2. Re-capture and re-run §3 to §6 for the frame, then update the ledger. A fix can move other nodes, so re-run the whole frame, not only the part you changed.
3. Stop when every check passes or every remaining difference has a ledger row that is `waiting on human` or `accepted by human`.

After three rounds with rows still `open`, stop and report them with the strips. Do not keep adjusting values by trial; an open row after three rounds usually means the structure differs from the design (wrong component, wrong layout model), so re-read the Figma node.

## 9. Fresh reviewer

You built the screen, so you expect it to match. After the loop is clean, hand the comparison to a reviewer with no memory of the build. Where the harness has subagents, spawn one with only these inputs: the Figma PNG, the implementation PNG, the stress captures, the spec sheet, and this prompt.

> Compare the implementation screenshot with the Figma screenshot. Assume they differ and find how. Work top to bottom in sections, zooming into each. For every difference give the element, the property, the Figma value, and the implementation value. Check the padding on each side of every container, the spacing between elements, position, size, radius, border, shadow, font family, size, weight, line height, text colour, icon size, text content and case, and missing or extra elements. Then check each stress capture for clipped or overlapping text, elements off screen, and unreachable actions. Do not read any code. End with the list, or the single word "identical" if you find nothing after checking every section.

Add each finding to the ledger and run §8 again. Without subagents, do the same pass yourself section by section on crops, and say in the report that no independent review ran.

## 10. What to report

State results as numbers, per frame:

- measured rows passing out of the total, for the box table and the text table
- bands over threshold in the last run (for example `0 of 12`), and the command used
- stress matrix: cases passing out of cases run
- behaviour table: rows passing, and the kind of evidence for each
- ledger counts: fixed, waiting on human, accepted
- the fresh reviewer's result
- what was not checked and why

"Looks the same" is not a result.
