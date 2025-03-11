local opts = { silent = true }

vim.keymap.set("n", "<S-t>", ":tabnew<CR>", opts)

vim.keymap.set("n", "[<Tab>", ":tabprevious<CR>", opts)
vim.keymap.set("n", "]<Tab>", ":tabnext<CR>", opts)

-- Move to previous/next
vim.keymap.set('n', ',q', ':bprevious<CR>', opts)
vim.keymap.set('n', ',w', ':bnext<CR>', opts)

-- Close buffer
vim.keymap.set('n', ',bd', ':bdelete<CR>', opts)
vim.keymap.set('n', ',bda', ':w <bar> %bd <bar> e# <bar> bd# <CR>', opts)

--  Alternative Buffer
vim.keymap.set("n", "<BS>", ":b#<CR>", opts)
