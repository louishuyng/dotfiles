local map = require 'utils.map'

local opt = {}

map("n", "<leader>nr", ":NR!<CR>:MaximizerToggle<CR>", opt)
map("v", "<leader>nr", ":NR!<CR>:MaximizerToggle<CR>", opt)
map("n", "<leader>wr", ":WR!<CR>", opt)
map("v", "<leader>wr", ":WR!<CR>", opt)
