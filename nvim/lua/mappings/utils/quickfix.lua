local opt = {silent = true}

vim.keymap.set("n", "<A-j>", ":cn<CR>", opt)
vim.keymap.set("n", "<A-k>", ":cp<CR>", opt)

vim.keymap.set("n", "qo", ":copen<CR>", opt)
vim.keymap.set("n", "qc", "<cmd>call setqflist([])<CR>", opt)
