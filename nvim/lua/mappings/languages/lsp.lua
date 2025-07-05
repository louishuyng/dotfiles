vim.keymap.set('n', 'gd', '<cmd>vsplit | lua vim.lsp.buf.definition()<CR>', {})
vim.keymap.set('n', 'gD', '<cmd>split | lua vim.lsp.buf.definition()<CR>', {})

vim.keymap.set('n', '<leader>s', ':Neotree source=document_symbols reveal=true<CR>', {
  noremap = true,
  silent = true,
})
