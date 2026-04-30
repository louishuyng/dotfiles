-- Treemacs-flavored highlights and git fringe signs for nvim-tree.
-- Idempotent: safe to call repeatedly (e.g. on ColorScheme).

local M = {}

local function hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

local function get_fg(group, fallback)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and h.fg then return h.fg end
  return fallback
end

local function get_bg(group, fallback)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and h.bg then return h.bg end
  return fallback
end

local function darken(color, amount)
  if type(color) ~= 'number' then return color end
  local r = math.floor(color / 65536) % 256
  local g = math.floor(color / 256) % 256
  local b = color % 256
  r = math.max(0, r - amount)
  g = math.max(0, g - amount)
  b = math.max(0, b - amount)
  return r * 65536 + g * 256 + b
end

function M.apply()
  local normal_bg = get_bg('Normal', 0x1a1b26)
  local tree_bg = darken(normal_bg, 8)
  local cursor_bg = get_bg('CursorLine', 0x292e42)
  local accent_magenta = get_fg('Keyword', 0xbb9af7)
  local accent_blue = get_fg('Function', 0x7aa2f7)
  local accent_green = get_fg('String', 0x9ece6a)
  local accent_yellow = get_fg('WarningMsg', 0xe0af68)
  local accent_red = get_fg('ErrorMsg', 0xf7768e)
  local accent_cyan = get_fg('Special', 0x7dcfff)
  local comment_fg = get_fg('Comment', 0x565f89)

  hl('NvimTreeNormal', { bg = tree_bg })
  hl('NvimTreeNormalNC', { bg = tree_bg })
  hl('NvimTreeEndOfBuffer', { bg = tree_bg, fg = tree_bg })
  hl('NvimTreeSignColumn', { bg = tree_bg })
  hl('NvimTreeCursorLine', { bg = cursor_bg })
  hl('NvimTreeCursorLineNr', { bg = cursor_bg, bold = true })

  hl('NvimTreeRootFolder', { fg = accent_magenta, bold = true })
  hl('NvimTreeIndentMarker', { fg = comment_fg })
  hl('NvimTreeFolderIcon', { fg = accent_blue })
  hl('NvimTreeOpenedFolderName', { fg = accent_blue, bold = true })
  hl('NvimTreeClosedFolderName', { fg = accent_blue })
  hl('NvimTreeEmptyFolderName', { fg = comment_fg })
  hl('NvimTreeModifiedFile', { fg = accent_yellow })
  hl('NvimTreeOpenedFile', { fg = accent_blue, italic = true })

  hl('NvimTreeGitDirty', { fg = accent_yellow })
  hl('NvimTreeGitStaged', { fg = accent_green })
  hl('NvimTreeGitNew', { fg = accent_cyan })
  hl('NvimTreeGitDeleted', { fg = accent_red })
  hl('NvimTreeGitIgnored', { fg = comment_fg })
  hl('NvimTreeGitMerge', { fg = accent_red, bold = true })
  hl('NvimTreeGitRenamed', { fg = accent_yellow })

  local sign_bg = tree_bg
  local function sign(name, color)
    vim.fn.sign_define(name, { text = '▎', texthl = name, numhl = name })
    hl(name, { fg = color, bg = sign_bg })
  end
  sign('NvimTreeGitDirtyIcon', accent_yellow)
  sign('NvimTreeGitStagedIcon', accent_green)
  sign('NvimTreeGitNewIcon', accent_cyan)
  sign('NvimTreeGitDeletedIcon', accent_red)
  sign('NvimTreeGitIgnoredIcon', comment_fg)
  sign('NvimTreeGitMergeIcon', accent_red)
  sign('NvimTreeGitRenamedIcon', accent_yellow)

  local diag = {
    { name = 'NvimTreeDiagnosticHintIcon', glyph = '', color = accent_blue },
    { name = 'NvimTreeDiagnosticInfoIcon', glyph = '', color = accent_cyan },
    { name = 'NvimTreeDiagnosticWarningIcon', glyph = '', color = accent_yellow },
    { name = 'NvimTreeDiagnosticErrorIcon', glyph = '', color = accent_red },
  }
  for _, d in ipairs(diag) do
    vim.fn.sign_define(d.name, { text = d.glyph, texthl = d.name, numhl = d.name })
    hl(d.name, { fg = d.color, bg = sign_bg })
  end
end

function M.attach_autocmd()
  local group = vim.api.nvim_create_augroup('TreemacsHighlights', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function() M.apply() end,
  })
end

return M
