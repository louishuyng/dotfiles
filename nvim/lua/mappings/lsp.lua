local map = require 'utils.map'

local opt = {}

map("n", "gff", ":vsplit<CR>gf", opt)
map("n", "gfh", ":split<CR>gf", opt)
