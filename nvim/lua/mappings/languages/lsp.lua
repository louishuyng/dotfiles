local toggle_auto_format =
    require"functions.toggle_auto_format".toggle_auto_format

vim.keymap.set("n", "gv", ":lua vim.cmd('vsplit');vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gh", ":lua vim.cmd('split');vim.lsp.buf.definition()<CR>")

vim.keymap.set("n", "<space>A", toggle_auto_format)
