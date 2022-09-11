local opts = {noremap = true, silent = true}

vim.keymap.set("n", "<Leader><Leader>i", "<cmd>IconPickerNormal<cr>", opts)
vim.keymap.set("i", "<C-i>", "<cmd>IconPickerInsert<cr>", opts)
