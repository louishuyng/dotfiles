local map = require 'utils.map'

local opt = {}

map("n", ",ga", ":Gwrite!<CR>", opt)
map("n", ",gc", ":Git commit<CR>", opt)
map("n", "<space>gp", ":Gpush", opt)
map("n", "<space>gf", ":Gpull", opt)
map("n", ",gs", ":Git<CR>:20wincmd_<CR>", opt, {silent = true})
map("n", "<space>gs", ":LazyGit<CR>", opt, {silent = true})
map("n", ",gb", ":Git blame<CR>", opt)
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
map("n", "gb",  ":GitBlameToggle<CR>", opt)
