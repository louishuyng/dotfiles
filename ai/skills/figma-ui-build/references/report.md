# Figma vs implementation report

The final deliverable for the human. It lives in `.ui-review/` and is never committed.

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

## PR description

Text only, no images or attachments:

| Screen/state | Figma node | Status | Notes |
| --- | --- | --- | --- |

Add one line saying that a local side-by-side report exists and how to regenerate it (stories + capture commands). Reviewers rebuild it locally or open the Storybook `design` tab.
