local map = require 'utils.map'

local opt = {
  silent = true
}

map('n', "<C-h>", ":lua require('Navigator').left()<CR>", opt)
map('n', "<C-k>", ":lua require('Navigator').up()<CR>", opt)
map('n', "<C-l>", ":lua require('Navigator').right()<CR>",opt)
map('n', "<C-j>", ":lua require('Navigator').down()<CR>", opt)
