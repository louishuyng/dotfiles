local M = {}

-- M.palette = {
--   base00 = '#0f0f0f',
--   base01 = '#161616',
--   base02 = '#212821',
--   base03 = '#3d5240',
--   base04 = '#6b8a6e',
--   base05 = '#d8e8d4',
--   base06 = '#e8f4e4',
--   base07 = '#f4faf2',
--   base08 = '#d4696e',
--   base09 = '#d4956a',
--   base0A = '#c8b86a',
--   base0B = '#6ac87a',
--   base0C = '#22d3ee',
--   base0D = '#6aa8d4',
--   base0E = '#a87ad4',
--   base0F = '#d4856a',
-- }

-- Deep Forest: dark green-tinted backgrounds, soft sage fg, natural accents
M.palette = {
  base00 = '#111411',
  base01 = '#161a16',
  base02 = '#1e2820',
  base03 = '#4a6650',
  base04 = '#7a9e80',
  base05 = '#d4edd0',
  base06 = '#e2f5de',
  base07 = '#eefaeb',
  base08 = '#e06c75',
  base09 = '#d4956a',
  base0A = '#d4b96a',
  base0B = '#7dc97d',
  base0C = '#72c4b8',
  base0D = '#72aad4',
  base0E = '#b07dd4',
  base0F = '#d48872',
}

function M.apply()
  local p = M.palette

  -- Telescope
  vim.api.nvim_set_hl(0, 'TelescopeBorder', { fg = p.base0B, bg = p.base01 })
  vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = p.base01 })
  vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = p.base01 })
  vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { fg = p.base0B, bg = p.base01 })
  vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { fg = p.base00, bg = p.base0B, bold = true })
  vim.api.nvim_set_hl(0, 'TelescopeTitle', { fg = p.base00, bg = p.base0D, bold = true })
  vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = p.base02 })
  vim.api.nvim_set_hl(0, 'TelescopeMatching', { fg = p.base0B, bold = true })

  -- NeoTree
  vim.api.nvim_set_hl(0, 'NeoTreeNormal', { fg = p.base05, bg = p.base01 })
  vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { fg = p.base05, bg = p.base01 })
  vim.api.nvim_set_hl(0, 'NeoTreeDimText', { fg = p.base03, bg = p.base01 })
  vim.api.nvim_set_hl(0, 'NeoTreeRootName', { fg = p.base0B, bg = 'NONE', bold = true, italic = false })
  vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { bg = p.base02 })
  vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker', { fg = p.base03 })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { fg = p.base0D })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = p.base0D })

  -- Alpha
  vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = p.base0B, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'AlphaFooter', { fg = p.base04, bg = 'NONE' })

  -- Statusline
  vim.api.nvim_set_hl(0, 'StatusLine', { fg = p.base05, bg = p.base01 })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = p.base04, bg = p.base01 })

  -- Search / Visual
  vim.api.nvim_set_hl(0, 'Search', { fg = p.base00, bg = p.base0A, bold = true })
  vim.api.nvim_set_hl(0, 'IncSearch', { fg = p.base00, bg = p.base0C, bold = true })
  vim.api.nvim_set_hl(0, 'Visual', { bg = p.base02 })

  -- General
  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = p.base0B, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'CursorLine', { bg = p.base02 })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = p.base0B, bg = p.base02, bold = true })
  vim.api.nvim_set_hl(0, 'CursorLineSign', { bg = p.base02 })
  vim.api.nvim_set_hl(0, 'CursorLineFold', { bg = p.base02 })
  vim.api.nvim_set_hl(0, 'MatchParen', { fg = p.base0C, bg = p.base02, bold = true })
  vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'WinBar', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'FoldColumn', { bg = 'NONE' })

  for _, group in ipairs { 'LineNr', 'LineNrAbove', 'LineNrBelow' } do
    vim.api.nvim_set_hl(0, group, { fg = p.base03, bg = 'NONE' })
  end
end

return M
