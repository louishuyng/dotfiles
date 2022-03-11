local map = require 'utils.map'

local opt = {}

map("n", ",ne", ":CHADopen<CR>", opt)
map("n", ",nf", ":CHADopen --always-focus<CR>", opt)
map("n", "<leader>l", "<cmd>call setqflist([]", opt)
