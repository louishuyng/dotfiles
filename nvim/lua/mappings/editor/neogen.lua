local map = require('utils.map')
local opt = { noremap = true, silent = true }

map("n", "<space>nf", ":lua require('neogen').generate()<CR>", opt)
