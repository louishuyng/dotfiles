local toggle_auto_format =
    require"functions.toggle_auto_format".toggle_auto_format

vim.keymap.set("n", "gv", ":Lspsaga goto_definition vsplit<CR>")
vim.keymap.set("n", "gs", ":Lspsaga goto_definition split<CR>")
vim.keymap.set("n", "<leader>A", toggle_auto_format)
vim.keymap.set("n", "<leader>v", ":Lspsaga outline<CR>")
