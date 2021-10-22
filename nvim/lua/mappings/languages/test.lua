local map = require 'utils.map'

local opt = {}

map("n", ",t", ":TestFile<CR>", opt)
map("n", ",s", ":TestNearest<CR>", opt)
map("n", ",l", ":TestLast<CR>", opt)
map("n", ",a", ":TestSuite<CR>", opt)
