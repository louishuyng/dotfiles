local map = require 'utils.map'

local opt = {}

map("n", ",ne", ":CHADopen<CR>", opt)
map("n", "<leader>l", "<cmd>call setqflist([]", opt)
