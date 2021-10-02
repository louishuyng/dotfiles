local map = require('utils.map')

local opt = {}

map("n", ",w", ":bnext<CR>", opt)
map("n", ",q", ":bprevious<CR>", opt)
map("n", ",bda", ":w <bar> %bd <bar> e# <bar> bd# <CR>", opt)
map("n", "<S-t>", ":tabnew<CR>", opt, {silent = true})
map("n", "1<Tab>", "1gt", opt, {silent = true})
map("n", "2<Tab>", "2gt", opt, {silent = true})
map("n", "3<Tab>", "3gt", opt, {silent = true})
