local map = require('utils.map').map

local opt = {}

vim.g.move_map_keys = 0
map("v", "<S-j>", "<Plug>MoveBlockDown", opt)
map("v", "<S-k>", "<Plug>MoveBlockUp", opt)
map("v", "<S-h>", "<Plug>MoveBlockLeft", opt)
map("v", "<S-l>", "<Plug>MoveBlockRight", opt)
