-- Adapter: projekt0n/github-nvim-theme → semantic palette.
--
-- Pinned to the high-contrast variants for maximum fg/bg separation:
--   - dark  : github_dark_high_contrast
--   - light : github_light_high_contrast
-- Swap the constants below if you'd rather use github_dark / github_dark_dimmed
-- / github_light_default — they all share the same Primer-style palette shape.
--
-- Palette shape (different from nightfox): nested Primer roles —
--   bg, fg.default/muted/subtle, canvas.{default,overlay,inset,subtle},
--   border.{default,muted}, neutral.{emphasisPlus,muted,subtle},
--   accent.{fg,muted,subtle}, success/attention/severe/danger.{fg,muted,subtle}.

local M = {}

local DARK_STYLE = 'github_dark_high_contrast'
local LIGHT_STYLE = 'github_light_high_contrast'

-- Green-forward "terminal phosphor" tweak. Greens are pulled from each
-- variant's own scale so they sit correctly against the canvas.
--   dark : green3 (#4ae168) lead, green4 (#26cd4d) deep
--   light: green5 (#117f32) lead, green6 (#055d20) deep (dark enough on light)
local GREEN = {
  [DARK_STYLE] = { lead = '#4ae168', deep = '#26cd4d' },
  [LIGHT_STYLE] = { lead = '#117f32', deep = '#055d20' },
}

-- Syntax: stock github_*_high_contrast is blue/purple/red dominant — functions
-- are purple (prettylights `entity`) and strings light blue (`string`), so code
-- barely shows green outside tags/regex. We retint the two highest-frequency
-- roles — functions (lead green) and strings (deep green, a shade darker so the
-- two stay distinguishable) — while leaving keywords red and numbers/constants
-- blue so the buffer keeps contrast instead of going monochrome. `func`/`string`
-- feed both legacy (`Function`/`String`) and treesitter (`@function`/`@string`).
local function specs_for(style)
  local g = GREEN[style]
  return { [style] = { syntax = { func = g.lead, string = g.deep } } }
end

-- nvim-tree: root folder + directory names default to plain fg; tint them green
-- to match the syntax lead. Root and opened folders keep their bold weight.
local function groups_for(style)
  local g = GREEN[style]
  return {
    [style] = {
      NvimTreeRootFolder = { fg = g.lead, style = 'bold' },
      NvimTreeFolderName = { fg = g.lead },
      NvimTreeOpenedFolderName = { fg = g.lead, style = 'bold' },
      NvimTreeEmptyFolderName = { fg = g.lead },
    },
  }
end

function M.setup()
  local ok, gh = pcall(require, 'github-theme')
  if ok then
    gh.setup({
      options = {
        transparent = true,
        hide_end_of_buffer = true,
        -- styles = {
        --   comments = 'italic',
        --   keywords = 'NONE',
        -- },
      },
      specs = vim.tbl_extend('force', specs_for(DARK_STYLE), specs_for(LIGHT_STYLE)),
      groups = vim.tbl_extend('force', groups_for(DARK_STYLE), groups_for(LIGHT_STYLE)),
    })
  end
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme(variant == 'light' and LIGHT_STYLE or DARK_STYLE)
end

function M.resolve(variant)
  local ok, palette = pcall(require, 'github-theme.palette')
  if not ok then
    return nil
  end
  local style = variant == 'light' and LIGHT_STYLE or DARK_STYLE
  local p = palette.load(style)
  if not p or type(p) ~= 'table' then
    return nil
  end

  -- Most fields are nested {default, muted, subtle, emphasis, ...}; a few
  -- top-level entries (`bg`, `fg`) are also strings in older versions. This
  -- helper picks whichever shape exists.
  local function pick(node, key)
    if node == nil then
      return nil
    end
    if type(node) == 'table' then
      return node[key] or node.default or node.fg or node.emphasis
    end
    return node
  end

  local canvas = p.canvas or {}
  local fg = p.fg or {}
  local neutral = p.neutral or {}
  local accent = p.accent or {}
  local success = p.success or {}
  local attention = p.attention or {}
  local danger = p.danger or {}
  local done = p.done or p.sponsors or {}

  local bg = pick(canvas, 'default') or (type(p.bg) == 'string' and p.bg) or '#0a0c10'
  local text = pick(fg, 'default') or (type(p.fg) == 'string' and p.fg) or '#f0f3f6'

  -- High-contrast canvas.overlay (#272b33) is barely lifted above the
  -- near-black #0a0c10 editor bg, so statusline/tabline/tree blend into
  -- the editor. Pin bg_alt to a clearly lifted chrome tone — #30363d
  -- happens to be the editor bg from github's normal (non-high-contrast)
  -- dark variant, so it reads as "one mode lighter" against high-contrast
  -- black. surface lifts one step further so selections sit visibly on
  -- top of the chrome layer in telescope/cmp/tree.
  local bg_alt, surface
  if variant == 'light' then
    bg_alt = pick(canvas, 'overlay') or bg
    surface = '#d0d7de' -- github light border tone — visible against #e7ecf0 chrome
  else
    bg_alt = '#242424'
    surface = '#1B1B1B'
  end

  return {
    bg = bg,
    bg_alt = bg_alt,
    bg_dim = pick(canvas, 'inset') or bg,
    surface = surface,
    surface_alt = pick(neutral, 'emphasis') or pick(neutral, 'emphasisPlus') or pick(canvas, 'subtle') or bg,
    overlay = pick(canvas, 'subtle') or bg,

    text = text,
    subtle = pick(fg, 'muted') or text,
    muted = pick(fg, 'subtle') or pick(fg, 'muted') or text,

    -- Brand accents: green (success) leads, blue (accent) supports, purple
    -- (done) contrasts — matches the family pattern of the other adapters.
    primary = pick(success, 'fg') or pick(success, 'emphasis'),
    secondary = pick(accent, 'fg') or pick(accent, 'emphasis'),
    tertiary = pick(done, 'fg') or pick(done, 'emphasis'),

    info = pick(accent, 'fg') or pick(accent, 'emphasis'),
    warn = pick(attention, 'fg') or pick(attention, 'emphasis'),
    error = pick(danger, 'fg') or pick(danger, 'emphasis'),
    success = pick(success, 'fg') or pick(success, 'emphasis'),
    attention = pick(attention, 'fg') or pick(attention, 'emphasis'),

    info_muted = pick(accent, 'muted') or pick(accent, 'fg'),
    warn_muted = pick(attention, 'muted') or pick(attention, 'fg'),
    error_muted = pick(danger, 'muted') or pick(danger, 'fg'),
    success_muted = pick(success, 'muted') or pick(success, 'fg'),

    -- Primer's *.subtle tones are ready-made dim accent backgrounds.
    bg_info = pick(accent, 'subtle') or pick(canvas, 'subtle') or bg,
    bg_warn = pick(attention, 'subtle') or pick(canvas, 'subtle') or bg,
    bg_error = pick(danger, 'subtle') or pick(canvas, 'subtle') or bg,
    bg_success = pick(success, 'subtle') or pick(canvas, 'subtle') or bg,
  }
end

return M
