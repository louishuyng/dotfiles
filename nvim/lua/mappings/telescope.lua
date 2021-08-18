local map = require('utils.map').map

local opt = {}

map("n", "<c-p>", "<cmd>Telescope git_files<cr>", opt, {silent = true})
map("n", "<space>f", "<cmd>Telescope live_grep<CR>", opt, {silent = true})
map("n", "<space>t", "<cmd>Telescope treesitter<CR>", opt, {silent = true})
map("n", "<space>b", "<cmd>Telescope buffers<CR>", opt, {silent = true})
map("n", "<space>h", "<cmd>Telescope oldfiles<CR>", opt, {silent = true})
