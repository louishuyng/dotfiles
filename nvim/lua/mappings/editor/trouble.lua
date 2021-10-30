local map = require 'utils.map'

local opt = {}

map("n", "<leader>xx", ":TroubleToggle<CR>", opt)
map("n", "gr", ":TroubleToggle lsp_references<CR>", opt)
