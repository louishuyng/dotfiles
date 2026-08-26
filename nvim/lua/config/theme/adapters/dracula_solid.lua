-- Adapter: Mofiqul/dracula.nvim → semantic palette, tuned to Gram's
-- "Dracula Solid".
--
-- Gram bundles three Dracula variants (assets/themes/dracula/dracula.json):
-- Dracula, Dracula Solid and Dracula Light (Alucard). Solid is the opaque one.
-- It draws from the same seven Dracula accents as dracula.nvim, but differs in
-- two ways this adapter corrects:
--
--   1. Chrome. Gram's is purple-shifted and its panels run far deeper
--      (#0a080c vs dracula.nvim's #21222c).
--   2. Group mapping. dracula.nvim points Keyword at cyan, Function at yellow
--      and @property at purple; Gram's syntax table says pink, green and cyan.
--
-- The `gram` table below is transcribed from that theme's style block and is
-- the single source for both the colorscheme overrides and the semantic roles.
--
-- Dark-only: dracula.nvim's load() hardcodes `background = "dark"`, so
-- assigning it to the light slot yields a dark editor. Alucard would be the
-- light counterpart, but no nvim port of it exists.

local M = {}

-- Values are Gram's Dracula Solid style keys; the comment names the key.
local gram = {
  -- Grounds, deepest → lightest.
  panel = '#0a080c', -- panel.background (the file tree)
  chrome = '#141119', -- status_bar / title_bar
  tab_off = '#1c1d26', -- tab.inactive_background
  neutral = '#242631', -- surface.background, and every diagnostic ground
  bg = '#282a36', -- editor.background
  indent = '#323230', -- editor.indent_guide
  -- editor.active_line.background (#44475a) needs no entry: dracula.nvim's
  -- `selection`, which drives CursorLine, is already that exact value.
  hover = '#504364', -- border.variant / element.hover
  selected = '#65547d', -- element.selected

  -- Ink.
  fg = '#f8f8f2', -- text / editor.foreground, and syntax.variable
  muted = '#a186c7', -- text.muted
  comment = '#6272a4', -- syntax.comment / syntax.preproc, also border.disabled

  -- Accents (syntax.*, the same seven listed under `accents`).
  purple = '#bd93f9', -- constant, number, enum, title
  pink = '#ff79c6', -- keyword, operator, punctuation, tag, constructor
  cyan = '#8be9fd', -- type, property
  green = '#50fa7b', -- function
  orange = '#ffb86c', -- variable.parameter, emphasis.strong
  yellow = '#f1fa8c', -- string
  red = '#ff5555', -- string.regex, deleted

  -- terminal.ansi.dim_* — genuine dimmed accents, unlike the bright_* set.
  dim_cyan = '#6fbaca',
  dim_yellow = '#c1c870',
  dim_red = '#cc4444',
  dim_green = '#40c862',

  -- Tinted grounds. Gram's error/warn/info/... backgrounds all collapse to
  -- `neutral` or carry alpha; these three are the opaque ones worth having.
  created_bg = '#222e1d', -- created.background
  deleted_bg = '#301b1b', -- deleted.background
  conflict_bg = '#5d4c2f', -- conflict.border
}

-- Only the groups where dracula.nvim disagrees with Gram's syntax table. The
-- treesitter captures are what colors real code; the legacy groups below them
-- cover buffers without a parser.
local function syntax_overrides()
  return {
    -- Legacy syntax groups.
    Keyword = { fg = gram.pink },
    Statement = { fg = gram.pink },
    Operator = { fg = gram.pink },
    Boolean = { fg = gram.pink },
    Special = { fg = gram.pink },
    Constant = { fg = gram.purple },
    Number = { fg = gram.purple },
    Function = { fg = gram.green },
    Identifier = { fg = gram.fg },
    Structure = { fg = gram.cyan },
    PreProc = { fg = gram.comment },

    -- Treesitter captures.
    ['@property'] = { fg = gram.cyan },
    ['@variable.member'] = { fg = gram.fg },
    ['@label'] = { fg = gram.fg },
    ['@type'] = { fg = gram.cyan },
    ['@boolean'] = { fg = gram.pink },
    ['@constructor'] = { fg = gram.pink },
    ['@attribute'] = { fg = gram.pink },
    ['@tag'] = { fg = gram.pink },
    ['@tag.delimiter'] = { fg = gram.pink },
    ['@keyword.function'] = { fg = gram.pink },
    ['@keyword.exception'] = { fg = gram.pink },
    ['@string.escape'] = { fg = gram.pink },
    ['@punctuation.delimiter'] = { fg = gram.pink },
    ['@constant.macro'] = { fg = gram.purple },
    ['@number.float'] = { fg = gram.purple },
    ['@markup.heading'] = { fg = gram.purple, bold = true },
  }
end

function M.setup()
  local ok, dracula = pcall(require, 'dracula')
  if not ok then
    return
  end
  dracula.setup({
    transparent_bg = false,
    -- Only the grounds move; the accents already match Gram's.
    colors = {
      menu = gram.panel, -- Pmenu + NvimTreeNormal
      black = gram.chrome, -- StatusLineTerm / WinSeparator / bufferline fill
      visual = gram.hover, -- Visual
      nontext = gram.indent, -- NonText / indent markers
    },
    overrides = syntax_overrides(),
  })
end

function M.apply(_)
  vim.o.background = 'dark'
  vim.cmd.colorscheme('dracula')
end

function M.resolve(_)
  return {
    bg = gram.bg,
    bg_alt = gram.panel,
    bg_dim = gram.tab_off,
    -- Gram's lifted grounds are purple-tinted; `surface` is what consumers use
    -- for selected rows (see ui/tree.lua), so it takes element.hover.
    surface = gram.hover,
    surface_alt = gram.selected,
    overlay = gram.comment,

    text = gram.fg,
    subtle = gram.muted,
    muted = gram.comment,

    -- Brand accents: green leads, cyan supports, pink contrasts —
    -- matches the family pattern of the other adapters.
    primary = gram.green,
    secondary = gram.cyan,
    tertiary = gram.pink,

    -- Gram's own status colors are softer pastels (#e67373, #e6e373, ...), but
    -- these roles sit next to dracula.nvim's Diagnostic* highlights in nvim, so
    -- they use the accents those highlights actually draw with. Dracula has no
    -- blue; cyan is its info tone.
    info = gram.cyan,
    warn = gram.yellow,
    error = gram.red,
    success = gram.green,
    attention = gram.orange,

    info_muted = gram.dim_cyan,
    warn_muted = gram.dim_yellow,
    error_muted = gram.dim_red,
    success_muted = gram.dim_green,

    bg_info = gram.neutral,
    bg_warn = gram.conflict_bg,
    bg_error = gram.deleted_bg,
    bg_success = gram.created_bg,
  }
end

return M
