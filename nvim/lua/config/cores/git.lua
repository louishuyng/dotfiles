-- Gitsign
local present, gitsigns = pcall(require, "gitsigns")
if not present then return end

local mapping = require 'mappings.source_control.gitsigns'

gitsigns.setup {
  signs = {
    add = {hl = 'GitSignsAdd', text = '┃'},
    change = {hl = 'GitSignsChange', text = '┃'},
    delete = {hl = 'GitSignsDelete', text = '┃'},
    topdelete = {hl = 'GitSignsDelete', text = '▔'},
    changedelete = {hl = 'GitSignsChange', text = '~'}
  },
  on_attach = mapping.gitsigns_mappings
}
