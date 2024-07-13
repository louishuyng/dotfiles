-- Gitsign
local present, gitsigns = pcall(require, "gitsigns")
if not present then return end

local mapping = require 'mappings.source_control.gitsigns'

gitsigns.setup {
  on_attach = mapping.gitsigns_mappings
}
