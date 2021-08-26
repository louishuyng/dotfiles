local map = require('utils.map').map

local opt = {}

map("n", "<space>nr", ":NR<CR>", opt)
map("v", "<space>nr", ":NR<CR>", opt)
map("n", "<space>wr", ":WR!<CR>", opt)
map("v", "<space>wr", ":WR!<CR>", opt)
