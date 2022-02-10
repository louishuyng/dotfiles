local map = require 'utils.map'

local opt = {}

map("n", "<leader>no", ":NR!<CR>:MaximizerToggle<CR>", opt)
map("v", "<leader>no", ":NR!<CR>:MaximizerToggle<CR>", opt)
map("n", "<leader>nw", ":WR!<CR>", opt)
map("v", "<leader>nw", ":WR!<CR>", opt)
