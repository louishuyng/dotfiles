local opt = { silent = true }

vim.keymap.set("n", "<A-j>", ":cn<CR>", opt)
vim.keymap.set("n", "<A-k>", ":cp<CR>", opt)

vim.keymap.set("n", "<leader>qo", ":copen<CR>", opt)
vim.keymap.set("n", "<leader>qd", "<cmd>call setqflist([])<CR>:cclose<CR>", opt)
