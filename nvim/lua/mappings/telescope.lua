local map = require 'utils.map'

local opt = {}

map("n", "<c-p>", "<cmd>Telescope git_files previewer=false<cr>", opt, {silent = true})
map("n", "<space>p", "<cmd>Telescope projects<cr>", opt, {silent = true})
map("n", "<space>f", "<cmd>Telescope live_grep layout_config={'width':0.7}<CR>", opt, {silent = true})
map("n", "<space>t", "<cmd>Telescope treesitter layout_config={'width':0.7}<CR>", opt, {silent = true})
map("n", "<space>b", "<cmd>Telescope buffers previewer=false<CR>", opt, {silent = true})
map("n", "<space>o", "<cmd>Telescope oldfiles previewer=false<CR>", opt, {silent = true})
map("n", "<space>ht", "<cmd>Telescope help_tags layout_config={'width':0.7}<CR>", opt, {silent = true})
