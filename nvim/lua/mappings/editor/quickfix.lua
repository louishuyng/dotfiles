local opt = {silent = true}

vim.keymap.set("n", "<A-j>", ":cn<CR>", opt)
vim.keymap.set("n", "<A-k>", ":cp<CR>", opt)
vim.keymap.set("n", "<leader>j", ":lnext<CR>", opt)
vim.keymap.set("n", "<leader>k", ":lprev<CR>", opt)

vim.keymap.set("n", "<leader>co", ":copen<CR>", opt)
vim.keymap.set("n", "<leader>cr", "<cmd>call setqflist([])<CR>", opt)
