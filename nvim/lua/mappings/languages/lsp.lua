vim.keymap.set("n", "gd", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", {})
vim.keymap.set("n", "gD", "<cmd>split | lua vim.lsp.buf.definition()<CR>", {})
