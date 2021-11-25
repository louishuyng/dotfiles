local map = require 'utils.map'

local opt = {}

map("n", "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR>", opt, { silent = true })
map("n", "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR>", opt, { silent = true })
map("n", "*", "*<Cmd>lua require('hlslens').start()<CR>", opt, { silent = true })
map("n", "#", "#<Cmd>lua require('hlslens').start()<CR>", opt, { silent = true })
map("n", "g*", "g*<Cmd>lua require('hlslens').start()<CR>", opt, { silent = true })
map("n", "g#", "g#<Cmd>lua require('hlslens').start()<CR>", opt, { silent = true })
map("n","<Esc><Esc>", "<Plug>anzu-clear-search-status", opt)
