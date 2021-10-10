local map = require 'utils.map'

local opt = {}

map("n", ",h", ":<C-u>split<CR>", opt)
map("n", ",v", ":<C-u>vsplit<CR>", opt)

map("n", ",e", ":e <C-R>=expand(\"%:p:h\") . \"/\" <CR>", opt)

map("v", "<C-x>", ":!pbcopy<CR>", opt)
map("v", "<C-c>", ":w !pbcopy<CR><CR>", opt)

map("v", "/", "y/<C-R>\"<CR>", opt)
map("n", "<C-j>", "<C-w>j", opt)
map("n", "<C-k>", "<C-w>k", opt)
map("n", "<C-l>", "<C-w>l", opt)
map("n", "<C-h>", "<C-w>h", opt)

map("n", "<C-s>", ":w!<CR>", opt)
map("v", "<C-s>", "<C-C>:w!<CR>", opt)
map("i", "<C-s>", "<C-O>:w!<CR>", opt)
map("n", "<C-d>", ":q!<CR>", opt)
map("v", "<C-d>", "<ESC>:q!<CR>", opt)
map("i", "<C-d>", "<ESC>:q!<CR>", opt)

-- Macro Apply Visual
map("v", ",m", ":normal @", opt)

-- Move Block
vim.g.move_map_keys = 0
map("v", "<S-j>", "<Plug>MoveBlockDown", opt)
map("v", "<S-k>", "<Plug>MoveBlockUp", opt)
map("v", "<S-h>", "<Plug>MoveBlockLeft", opt)
map("v", "<S-l>", "<Plug>MoveBlockRight", opt)

map("v", "<space>ex", ":w !", opt)
