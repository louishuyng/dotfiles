vim.keymap.set("n", "gv",
  ":lua vim.cmd('vsplit');require('telescope.builtin').lsp_definitions()<CR>")
vim.keymap.set("n", "gs",
  ":lua vim.cmd('split');require('telescope.builtin').lsp_definitions()<CR>")
