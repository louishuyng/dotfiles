# Reading Figma: MCP first, browser fallback

Checked 2026-11-09. Items marked [U] are unverified.

## 1. Figma MCP server

- **Endpoints:** remote `https://mcp.figma.com/mcp` (recommended, link-based) or desktop `http://127.0.0.1:3845/mcp`. The desktop server needs Dev Mode → "Enable desktop MCP server", a Dev/Full seat, and supports prompting from the current selection.
- **Node ID:** for a URL `figma.com/design/<fileKey>/<name>?node-id=1-2`, the node is `1:2`. Send the colon form.
- Tool list: https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/

| Tool | Use |
| --- | --- |
| `get_metadata` | XML outline of IDs, names, types, sizes. Call it first on a big frame. |
| `get_design_context` | Structured design plus code, React+Tailwind by default. It replaced `get_code`. |
| `get_variable_defs` | Variables and styles **used in the selection**: color, spacing, typography. |
| `get_screenshot` | PNG of the node. Use it as the visual truth and the report's Figma image. |
| `get_code_connect_map` | Code Connect mappings: which code component an instance is. |
| `search_design_system` | Find components, variables, and styles by name. |
| `get_motion_context` | Keyframes and easing for prototyped motion. |
| `download_assets` (remote) | Export URLs for up to 20 nodes per call. |

### Workflow (Figma's own rules)

1. Run `get_metadata` on the frame. Then call `get_design_context` per section (header, card, list row) rather than on the whole screen. Large selections truncate or error.
2. Run `get_variable_defs` on the same nodes.
3. Run `get_screenshot` on each frame and variant you implement.
4. A `<CodeConnectSnippet>` in the output means "use this repo component with these props". Never rebuild it from the markup.
5. The generated code shows design intent. It is not the final code style. Translate it into the repo's components and tokens.
6. Use asset sources the MCP returns, such as localhost URLs. Don't add icon packages or placeholders.

### Rate limits (tool calls)

| Plan | Limit |
| --- | --- |
| View/Collab seats | 20/month |
| Professional Dev/Full | 200/day, 10/min |
| Organization Dev/Full | 200/day, 15/min |
| Enterprise Dev/Full | 600/day, 20/min |

Budget your calls:

- Fetch each node once.
- Cache the results in `.ui-review/figma/` (JSON, PNG) for the session.
- Don't re-fetch to "double-check".

Source: https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/

## 2. Bound token vs raw value

This decides the token gate (see `fidelity.md`).

- **Bound:** the output contains a `var(--name, fallback)` style reference, e.g. `bg-[var(--color\/brand\/600,#2563eb)]`, and the name appears in `get_variable_defs` [U: the exact syntax is seen in practice, not documented]. Slashes are escaped. Map `color/brand/600` to the repo's naming.
- **Raw:** a bare literal (`bg-[#2563eb]`, `p-[16px]`) with no matching variable. This is a designer-side detached value. Report it. Don't invent a token.
- If `get_variable_defs` returns nothing, the frame uses no variables. Ask for the variable names explicitly by naming the tool. If it is still empty, report it.
- **Modes (light/dark):** the output is probably resolved for the frame's applied mode [U]. Implement the other mode from the repo token's mode values. If the design has a dark frame, fetch that frame too.
- Most reliable: the REST node JSON has `boundVariables` with a `variableId` on bound properties.

## 3. Fallback: signed-in browser via aside

Use this when MCP is missing, rate-limited (429 or limit message), or returns truncated or empty output. Load the `aside-browser` skill and follow `aside guide`. Then:

1. Open the frame URL. Press Shift+D for Dev Mode and select the node by its URL `node-id`.
2. Read the Inspect panel:
   - layout (auto-layout padding, gap, size)
   - colors
   - typography (style name, family, weight, size, line height, letter spacing)
   - text strings exactly as written
   - component name and properties
   - **variables**: a variable name means bound; a bare hex/px means raw
3. With nothing selected, Variables → "Open variables table" lists the file's tokens and modes. Use it for the token gate.
4. Take the frame screenshot: the Export section in Inspect (PNG @2x/3x), or an aside screenshot of the canvas zoomed to 100% of the frame. Save it to `.ui-review/figma/`.
5. Record in the report that values came from the browser. Text read from a rendered panel can be wrong, so cross-check each number twice.

## 4. Fallback: REST API (needs the user's PAT)

Use this only if the user provides `FIGMA_TOKEN`. Never commit the token or print it in logs.

- Node JSON (fills, `style` typography, padding and itemSpacing, `boundVariables`):
  `GET https://api.figma.com/v1/files/:key/nodes?ids=1:2` with header `X-Figma-Token: $FIGMA_TOKEN`
- Rendered PNG:
  `GET https://api.figma.com/v1/images/:key?ids=1:2&format=png&scale=3`
  Returns `{images:{id:url}}`. A `null` url means the render failed.
- Variables with `valuesByMode` (Enterprise only, otherwise 403):
  `GET /v1/files/:key/variables/local`
- Rate limits are tight, 10–20/min. On 429, wait `Retry-After` seconds.
- Docs: https://developers.figma.com/docs/rest-api/file-endpoints/

## When nothing works

Stop. Tell the user which access failed and what you need, for example "share the frame with my seat" or "paste the Inspect values". Never implement from memory or guess values from a low-resolution screenshot.
