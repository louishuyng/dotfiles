local map = require 'utils.map'

local opt = {}

map("n", "<c-p>", "<cmd>Telescope find_files hidden=true layout_config={'width':0.7}<cr>", opt, {silent = true})
map("n", "<leader>f", "<cmd>Telescope live_grep layout_config={'width':0.7}<CR>", opt, {silent = true})
map("n", "<leader>t", "<cmd>Telescope treesitter layout_config={'width':0.7}<CR>", opt, {silent = true})
map("n", "<leader>h", "<cmd>Telescope oldfiles previewer=false cwd_only=true<CR>", opt, {silent = true})
map("n", "<leader>p", "<cmd>Telescope project<CR>", opt, {silent = true})
map("n", "<leader>vrc", "<cmd>Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>", opt, {silent = true})
