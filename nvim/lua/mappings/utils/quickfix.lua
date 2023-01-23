local opt = {silent = true}

vim.keymap.set("n", "<Tab>", ":cn<CR>", opt)
vim.keymap.set("n", "<S-Tab>", ":cp<CR>", opt)

vim.keymap.set("n", "qo", ":copen<CR>", opt)
vim.keymap.set("n", "qc", "<cmd>call setqflist([])<CR>", opt)
