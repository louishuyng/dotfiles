local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Tab
map("n", "<S-t>", ":tabnew<CR>", opts)

map("n", "[<Tab>", ":tabprevious<CR>", opts)
map("n", "]<Tab>", ":tabnext<CR>", opts)

-- Move to previous/next
map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)

-- Re-order to previous/next
map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)

-- Close buffer
map('n', ',bd', ':bdelete<CR>', opts)
map('n', ',bda', ':w <bar> %bd <bar> e# <bar> bd# <CR>', opts)

--  Alternative Buffer
map("n", "<BS>", ":b#<CR>", opts)
