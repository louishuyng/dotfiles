local map = require('utils.map').map

local opt = {}

map("n", "n", "<Plug>(anzu-n-with-echo)", opt)
map("n", "N", "<Plug>(anzu-N-with-echo)", opt)
map("n", "*", "<Plug>anzu-star-with-echo", opt)
map("n", "#", "<Plug>anzu-sharp-with-echo", opt)
map("n","<Esc><Esc>", "<Plug>anzu-clear-search-status", opt)
