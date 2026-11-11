# Figma vs implementation report

Two deliverables: a local `report.html` for the human, and a PR description with screenshots and videos for reviewers. Neither puts a file in git.

## Keep evidence out of git

```sh
grep -qxF '.ui-review/' .git/info/exclude || echo '.ui-review/' >> .git/info/exclude
```

`.git/info/exclude` is local, so the repo's `.gitignore` stays untouched. Before every commit:

```sh
git status --porcelain | grep -E '\.(png|jpe?g|gif|mp4|mov|webm)$|\.ui-review/'
```

This must print nothing. If it prints anything, unstage it.

## Layout

```
.ui-review/
  design-map.md           tokens + components map (fidelity.md §1)
  figma/<node-id>.png     get_screenshot / export, same scale as impl
  figma/<node-id>.json    cached design context + variable defs
  impl/<story-or-screen>.png
  diff/<story-or-screen>.png   optional, when a diff tool already exists
  device/                 real-iPhone screenshots + recordings
  pr/                     exports for the PR description (see "PR evidence")
  report.html
```

## Capture rules

- Use the same size and scale on both sides. For an iPhone frame at 402pt, export Figma at @3x and capture the Simulator or device at @3x. Crop the Figma mock status bar if the implementation shows the real one, and note it.
- Use the same data. The fixture strings should match the Figma sample text, so differences are real.
- Pixel diff is optional. Use `odiff` or `pixelmatch` only when already installed, and don't add a dependency for it. Treat the mismatch % as a signal, not a pass/fail: fonts and anti-aliasing add noise.

## report.html

Write a single static file with relative image paths and no external requests. One row per screen/state:

```html
<!doctype html><meta charset="utf-8"><title>UI review — TICKET</title>
<style>
  :root { color-scheme: light dark; font: 14px/1.4 -apple-system, system-ui, sans-serif }
  body { margin: 16px; background: Canvas; color: CanvasText }
  .row { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin: 24px 0 }
  .row img { width: 100%; border: 1px solid #8884 }
  .ok { color: #1a7f37 } .bad { color: #cf222e } .warn { color: #9a6700 }
  @media (max-width: 700px) { .row { grid-template-columns: 1fr } }
</style>
<h1>TICKET — feature</h1>
<p>Branch · commit · device/simulator · Figma file link · data source (MCP / browser / REST)</p>
<h2>1. Cart — Default</h2>
<p><a href="FIGMA_NODE_URL">Figma</a> · story <code>features-checkout-1-cart--default</code></p>
<div class="row">
  <figure><img src="figma/12-345.png" alt="Figma: Cart default"><figcaption>Figma</figcaption></figure>
  <figure><img src="impl/features-checkout-1-cart--default.png" alt="Implementation: Cart default"><figcaption>Implementation</figcaption></figure>
  <figure><img src="diff/features-checkout-1-cart--default.png" alt="Pixel diff"><figcaption>Diff 0.8%</figcaption></figure>
</div>
<ul>
  <li class="ok">Tokens: all bound</li>
  <li class="warn">Title letter-spacing −0.34 (Figma −2%)</li>
  <li class="bad">Card radius 12 vs Figma 16: token radius.lg drift, awaiting decision</li>
</ul>
```

Below the rows, add these sections:

1. **Token check** table (fidelity.md §2) and the decisions made.
2. **Text audit:** every string with a ✓ or the mismatch.
3. **Native behaviour** (ios-native.md): each section passed/failed/skipped with the reason, and which device.
4. **Storybook:** the sidebar tree as text, in order.
5. **Assumptions:** what the design didn't specify and what you chose.
6. **Not checked:** anything blocked (no device, no MCP quota), stated plainly.

Open it with `open .ui-review/report.html` and give the human the absolute path.

## PR evidence

Reviewers judge fidelity from the PR description alone, so it carries the images and videos. They are GitHub attachments, not repo files.

### Export images (`.ui-review/pr/`)

- One image per screen/state per side: `<n>-<state>-figma.png` and `<n>-<state>-impl.png`. Use PNG, not JPEG, so text edges stay sharp.
- Full resolution: iPhone frames at @3x (a 402pt frame is 1206 px wide), web frames at @2x. Both sides at the same size, same data, same light/dark mode.
- Crop to the device screen. No Simulator chrome, no desktop around a browser window. Crop the status bar on both sides or neither.
- Add a zoomed crop (`<n>-<state>-detail-figma.png` / `-impl.png`) when the review point is small: type ramp, icon alignment, a hairline, a radius. Crop the region at full resolution; never upscale.
- Each file must be under 10 MB. A @3x PNG phone screen is usually 1–3 MB.

### Record videos (behaviour)

Record when a still can't show the change: transitions, swipe-back, sheet dismiss, large-title collapse, keyboard, haptic-paired actions, loading to content.

- Simulator: `xcrun simctl io booted recordVideo --codec=h264 .ui-review/pr/<n>-<behaviour>.mp4`, stop with Ctrl-C. Physical iPhone: see `real-device.md`.
- One behaviour per clip, 5–20 s, trimmed to the action. MP4 (H.264), under 10 MB (GitHub's limit on free plans). If too big and `ffmpeg` is installed: `ffmpeg -i in.mov -c:v libx264 -crf 23 -vf "scale=-2:1280" -an out.mp4`.
- Record at real speed. Slow motion only as an extra clip, labelled so.

### Upload

GitHub has no API for description attachments, so upload through the signed-in browser (aside, or Playwright `browser_file_upload`):

1. Create the PR first through the repo's ship workflow, then open its description editor.
2. Attach the files from `.ui-review/pr/` via the "Paste, drop, or click to add files" input. GitHub inserts `https://github.com/user-attachments/assets/<id>` links.
3. Rewrite each image link into the sized markup below and save the description.

On a private repo these attachments are visible to repo members only. Still, use mock data only: no real user data, tokens, or internal URLs in any frame.

If the browser upload isn't possible, give the human the `.ui-review/pr/` path and the ready-to-paste body, and list the upload under "Not checked".

### Sizing

Set the display width with `<img width>`. GitHub serves the full-resolution file, so a 320 px display of a 1206 px image is crisp on retina, and clicking it opens full size.

| Content | `width` | Why |
| --- | --- | --- |
| Phone screen, side by side | `320` | Two fit GitHub's ~880 px column; text is readable without zooming |
| Detail crop | `420` | Big enough to judge type and alignment |
| Tablet / web frame, side by side | `420` | Two per row |
| Wide web frame, alone | `860` | Full column width |

Video links render as an inline player at the column width. Put each URL on its own line.

### Body template

```markdown
## Design fidelity

Figma: <file link> · Device: iPhone 16 Pro (iOS 18.1), Simulator + physical · Data: mock fixtures

### 1. Cart — Default ([Figma](FIGMA_NODE_URL))

| Figma | Implementation |
| :---: | :---: |
| <img width="320" alt="Figma: Cart default" src="https://github.com/user-attachments/assets/…"> | <img width="320" alt="Implementation: Cart default" src="https://github.com/user-attachments/assets/…"> |

Detail — price row type ramp:

| Figma | Implementation |
| :---: | :---: |
| <img width="420" alt="Figma: price row" src="…"> | <img width="420" alt="Implementation: price row" src="…"> |

### Behaviour

**Swipe back from Cart to Product** (physical iPhone, real speed)

https://github.com/user-attachments/assets/…

### Summary

| Screen/state | Figma node | Status | Notes |
| --- | --- | --- | --- |
| 1. Cart — Default | 12:345 | ✓ match | |
| 1. Cart — Empty | 12:400 | ⚠ deviation | radius.lg drift, decision: keep token |

Not checked: <list, or "none">
```

Put dark mode in its own rows, not in the same image. Group many states under `<details><summary>States</summary> … </details>` so the description stays scannable; keep the default state open.
