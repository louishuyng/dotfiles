local map = require('utils.map').map

local opt = {}

map("n", "<space>xx", ":TroubleToggle<CR>", opt)
map("n", "gr", ":TroubleToggle lsp_references<CR>", opt)
