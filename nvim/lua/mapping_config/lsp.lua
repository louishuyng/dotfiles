local map = require('utils.map').map

local opt = {}

map("n", "gff", ":vsplit<CR>gf", opt)
map("n", "gfh", ":split<CR>gf", opt)

map("n", "gr", ":Lspsaga lsp_finder<CR>", opt, {silent = true})
map("n", "gd", ":Lspsaga preview_definition<CR>", opt, {silent = true})
map("n", "ac", ":Lspsaga code_action<CR>", opt, {silent = true})
map("n", "K", ":Lspsaga hover_doc<CR>", opt, {silent = true})
map("n", "]d", ":Lspsaga diagnostic_jump_next<CR>", opt, {silent = true})
map("n", "[d", ":Lspsaga diagnostic_jump_prev<CR>", opt, {silent = true})
