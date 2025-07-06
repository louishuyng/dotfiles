-- Gitsign
local present, gitsigns = pcall(require, 'gitsigns')
if not present then
  return
end

local mapping = require 'mappings.source_control.gitsigns'

local icons = {
  BoldLineLeft = '▎',
  BoldLineMiddle = '┃',
  BoldLineDashedMiddle = '┋',
  TriangleShortArrowRight = '',
}

gitsigns.setup {
  on_attach = mapping.gitsigns_mappings,
  word_diff = true,
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
  kind = 'auto',
  mappings = {
    status = {
      ['o'] = 'Toggle',
      ['b'] = 'OpenTree',
    },
  },
}
