local map = require 'utils.map'

local opt = {}

map("n", "<leader>ga", ":Gwrite!<CR>", opt)
map("n", "<leader>gc", ":Git commit<CR>", opt)
map("n", "<leader>gl", ":Git log<CR>", opt)
map("n", "<leader>gs", ":Git<CR>:20wincmd_<CR>", opt, {silent = true})
map("n", "<leader>gd", ":Gvdiff!<CR>", opt)
map("n", "dh", ":diffget //2<CR>", opt)
map("n", "dl", ":diffget //3<CR>", opt)
map("n", ",go", ":.Gbrowse<CR>", opt)
map("n", ",gd", ":q!<CR> :Gedit!<CR>", opt)
map("n", "]h",  "<Plug>(GitGutterNextHunk)", opt)
map("n", "[h",  "<Plug>(GitGutterPrevHunk)", opt)
map("n", "ga",  "<Plug>(GitGutterStageHunk)", opt)
map("n", "gu",  "<Plug>(GitGutterUndoHunk)", opt)
map("n", "gp",  "<Plug>(GitGutterPreviewHunk)", opt)
map("n", "gp",  "<Plug>(GitGutterPreviewHunk)", opt)
map("n", "<leader>gb",  ":Git blame<CR>", opt)
map("n", "<leader>gm",  ":GitMessenger<CR>", opt)
map("n", "<leader>;",  ":lua require('plugins.git_worktree').pull()<CR>", opt)
map("n", "<leader>gp", ":lua require('plugins.git_worktree').push()<CR>", opt)
