-- Gitsign
local present, gitsigns = pcall(require, 'gitsigns')
if not present then
  return
end

local mapping = require 'mappings.source_control.gitsigns'

gitsigns.setup {
  on_attach = mapping.gitsigns_mappings,
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
