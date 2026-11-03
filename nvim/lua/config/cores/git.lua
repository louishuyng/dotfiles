-- Gitsign
local present, gitsigns = pcall(require, 'gitsigns')
if not present then
  return
end

require('git-conflict').setup()

local mapping = require 'mappings.source_control.gitsigns'

local icons = {
  BoldLineLeft = '▎',
  BoldLineMiddle = '┃',
  BoldLineDashedMiddle = '┋',
  TriangleShortArrowRight = '',
}

gitsigns.setup {
  on_attach = mapping.gitsigns_mappings,
  word_diff = false,
  signs = {
    add = {
      text = icons.BoldLineMiddle,
    },
    change = {
      text = icons.BoldLineDashedMiddle,
    },
    delete = {
      text = icons.TriangleShortArrowRight,
    },
    topdelete = {
      text = icons.TriangleShortArrowRight,
    },
    changedelete = {
      text = icons.BoldLineMiddle,
    },
  },
}

local neogit = require('neogit')

neogit.setup {
  kind = 'split_above',
  commit_editor = { show_staged_diff = false },
  mappings = {
    status = {
      ['o'] = 'Toggle',
    },
  },
}

-- Neogit keeps each hash/ref/author/date segment's own fg on the active line,
-- so themes that give this a bright bg (cyberdream, jetbrains) make it unreadable.
require('config.theme.palette').on_change(function(c)
  vim.api.nvim_set_hl(0, 'NeogitActiveItem', { bg = c.surface, bold = true })
end)
