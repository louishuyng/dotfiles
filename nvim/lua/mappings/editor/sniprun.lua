local opts = {noremap = true, silent = true}

vim.keymap.set("v", "<leader>r", ":SnipRun<CR>", opts)
vim.keymap.set("n", "<leader>r", ":SnipRun<CR>", opts)
