-- Theme-agnostic nvim-tree highlights.
--
-- Pins the file tree to the chrome layer (bg_alt) — same plane as the
-- statusline and tabline — so the tree always sits visibly off the
-- editor canvas regardless of which theme is active. Some colorschemes
-- (catppuccin, github-theme) leave NvimTreeNormal at the editor bg by
-- default; this consumer normalises that.

local palette = require('config.theme.palette')

local function setup_highlights(c)
  if not next(c) then
    return
  end

  local hl = vim.api.nvim_set_hl

  -- Chrome layer: tree bg + filler tracks
  hl(0, 'NvimTreeNormal', { bg = c.bg_alt, fg = c.text })
  hl(0, 'NvimTreeNormalNC', { bg = c.bg_alt, fg = c.text })
  hl(0, 'NvimTreeEndOfBuffer', { bg = c.bg_alt, fg = c.bg_alt })

  -- Set explicitly (not a link): nvim-tree only `hi def link`s this group, so
  -- once anything defines it with another bg (e.g. left over from a theme
  -- switch) the def link never reclaims it and the git/signcolumn band keeps
  -- the stale (often editor-bg) colour. Forcing bg_alt here on every
  -- ColorScheme pins the gutter to the tree's chrome layer.
  -- hl(0, 'NvimTreeSignColumn', { bg = c.bg_alt, fg = c.text })
  -- hl(0, 'NvimTreeStatusLine', { bg = c.bg_alt, fg = c.muted })
  -- hl(0, 'NvimTreeStatusLine', { bg = c.bg_alt, fg = c.muted })
  -- hl(0, 'NvimTreeWinSeparator', { bg = c.bg_alt, fg = c.bg_alt })
  -- hl(0, 'NvimTreeStatusLineNC', { bg = c.bg_alt, fg = c.muted })
  -- hl(0, 'NvimTreeVertSplit', { bg = c.bg_alt, fg = c.bg_alt })
  --
  -- -- Active row lifts to surface so it reads as raised against the panel.
  hl(0, 'NvimTreeCursorLine', { bg = c.surface })
  hl(0, 'NvimTreeCursorColumn', { bg = c.surface })
  hl(0, 'NvimTreeCursorLineNr', { fg = c.primary, bold = true })
  -- --
  -- -- -- Structural accents
  -- hl(0, 'NvimTreeRootFolder', { fg = c.primary, bold = true })
  -- hl(0, 'NvimTreeFolderName', { fg = c.text })
  -- hl(0, 'NvimTreeOpenedFolderName', { fg = c.secondary, bold = true })
  -- hl(0, 'NvimTreeEmptyFolderName', { fg = c.muted })
  -- hl(0, 'NvimTreeSymlink', { fg = c.tertiary })
  -- hl(0, 'NvimTreeSpecialFile', { fg = c.attention, bold = true })
  -- hl(0, 'NvimTreeExecFile', { fg = c.success })
  -- hl(0, 'NvimTreeIndentMarker', { fg = c.muted })
  -- --
  -- -- -- Git / modified state in the tree
  -- hl(0, 'NvimTreeGitDirty', { fg = c.warn, bg = c.bg_alt })
  -- hl(0, 'NvimTreeGitNew', { fg = c.success, bg = c.bg_alt })
  -- hl(0, 'NvimTreeGitStaged', { fg = c.success, bg = c.bg_alt })
  -- hl(0, 'NvimTreeGitDeleted', { fg = c.error, bg = c.bg_alt })
  -- hl(0, 'NvimTreeGitMerge', { fg = c.attention, bg = c.bg_alt })
  -- hl(0, 'NvimTreeGitRenamed', { fg = c.info, bg = c.bg_alt })
  -- hl(0, 'NvimTreeGitIgnored', { fg = c.muted, bg = c.bg_alt })
  -- hl(0, 'NvimTreeModifiedFile', { fg = c.attention, bg = c.bg_alt })
end

palette.on_change(setup_highlights)
