local opt = {silent = true}

vim.keymap.set("n", "<A-l>", ":cn<CR>", opt)
vim.keymap.set("n", "<A-h>", ":cp<CR>", opt)
vim.keymap.set("n", "<leader>j", ":lnext<CR>", opt)
vim.keymap.set("n", "<leader>k", ":lprev<CR>", opt)

vim.keymap.set("n", "qo", ":copen<CR>", opt)
vim.keymap.set("n", "qc", "<cmd>call setqflist([])<CR>", opt)
