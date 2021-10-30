local map = require 'utils.map'

local opt = {}

map("n", "<c-p>", "<cmd>Telescope git_files previewer=false<cr>", opt, {silent = true})
map("n", "<leader>f", "<cmd>Telescope live_grep layout_config={'width':0.7}<CR>", opt, {silent = true})
map("n", "<leader>t", "<cmd>Telescope treesitter layout_config={'width':0.7}<CR>", opt, {silent = true})
map("n", "<leader>b", "<cmd>Telescope buffers previewer=false<CR>", opt, {silent = true})
map("n", "<leader>o", "<cmd>Telescope oldfiles previewer=false<CR>", opt, {silent = true})
map("n", "<leader>ht", "<cmd>Telescope help_tags layout_config={'width':0.7}<CR>", opt, {silent = true})
