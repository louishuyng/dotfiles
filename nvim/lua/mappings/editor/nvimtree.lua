local map = require 'utils.map'

local opt = {}

map("n", ",ne", ":NvimTreeToggle<CR>", opt)
map("n", ",nf", ":NvimTreeFindFile<CR>", opt)
