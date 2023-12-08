local toggle_auto_format =
    require"functions.toggle_auto_format".toggle_auto_format

vim.keymap.set("n", "gv",
               ":lua vim.cmd('vsplit');require('telescope.builtin').lsp_definitions()<CR>")
vim.keymap.set("n", "gs",
               ":lua vim.cmd('split');require('telescope.builtin').lsp_definitions()<CR>")

vim.keymap.set("n", "<leader>A", toggle_auto_format)
vim.keymap.set("n", "<leader>v", ":Lspsaga outline<CR>")
