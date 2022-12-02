local opt = {silent = true}

vim.keymap.set("n", "<c-]>", ":cn<CR>", opt)
vim.keymap.set("n", "<c-[>", ":cp<CR>", opt)
vim.keymap.set("n", "<leader>j", ":lnext<CR>", opt)
vim.keymap.set("n", "<leader>k", ":lprev<CR>", opt)

vim.keymap.set("n", "qo", ":copen<CR>", opt)
vim.keymap.set("n", "qc", "<cmd>call setqflist([])<CR>", opt)
