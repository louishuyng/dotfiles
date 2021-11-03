local map = require 'utils.map'

local opt = {}

map("n", ",ga", ":Gwrite!<CR>", opt)
map("n", ",gc", ":Git commit<CR>", opt)
map("n", ",gl", ":Git log<CR>", opt)
map("n", ",gs", ":Git<CR>:20wincmd_<CR>", opt, {silent = true})
map("n", "<leader>gs", ":LazyGit<CR>", opt, {silent = true})
map("n", ",gd", ":Gvdiff!<CR>", opt)
map("n", "dh", ":diffget //2<CR>", opt)
map("n", "dl", ":diffget //3<CR>", opt)
map("n", ",go", ":.Gbrowse<CR>", opt)
map("n", ",gD", ":q!<CR> :Gedit!<CR>", opt)
map("n", "]h",  "<Plug>(GitGutterNextHunk)", opt)
map("n", "[h",  "<Plug>(GitGutterPrevHunk)", opt)
map("n", "ga",  "<Plug>(GitGutterStageHunk)", opt)
map("n", "gu",  "<Plug>(GitGutterUndoHunk)", opt)
map("n", "gp",  "<Plug>(GitGutterPreviewHunk)", opt)
map("n", "gp",  "<Plug>(GitGutterPreviewHunk)", opt)
map("n", ",gb",  ":Git Blame<CR>", opt)
map("n", "<leader>gm",  ":GitMessenger<CR>", opt)
map("n", "<leader>;",  ":lua require('plugins.git_worktree').pull()<CR>", opt)
map("n", "<leader>gp", ":lua require('plugins.git_worktree').push()<CR>", opt)
