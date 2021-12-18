local map = require 'utils.map'

local opt = {}

map("n", ",h", ":<C-u>split<CR>", opt)
map("n", ",v", ":<C-u>vsplit<CR>", opt)

map("n", ",e", ":e <C-R>=expand(\"%:p:h\") . \"/\" <CR>", opt)

map("v", "<C-x>", ":!pbcopy<CR>", opt)
map("v", "<C-c>", ":w !pbcopy<CR><CR>", opt)

map("v", "/", "*", opt)
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
map("v", "<S-j>", ":m'>+<CR>gv=gv", opt)
map("v", "<S-k>", ":m-2<CR>gv=gv", opt)

map("v", "<leader>ex", ":w !", opt)

-- Sorting
map("v", "<leader>so", ":sort<CR>", opt)

-- Open URL
map("n", "<leader>o", ":call OpenUrlUnderCursor()<CR>", opt)

-- Replace
map("n", "r;", "yiw:%s/<C-R>\"/", opt)

-- Restart Service
map("n", "sr;", ":silent !brew services restart ", opt)

-- Packer
map("n", "<space>pi", ":PackerInstall<CR>", opt)
map("n", "<space>pc", ":PackerCompile<CR>", opt)
map("n", "<space>pr", ":PackerClean<CR>", opt)
