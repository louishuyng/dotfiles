vim.keymap.set("n", "gd", "<cmd>vsplit | :Lspsaga goto_definition<CR>", {})
vim.keymap.set("n", "gD", "<cmd>split | :Lspsaga goto_definition<CR>", {})

vim.keymap.set("n", "<leader>v", ":Lspsaga outline<CR>")
