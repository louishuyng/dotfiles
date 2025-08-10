vim.lsp.config('sqlls', {
  cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
  filetypes = { 'sql', 'mysql' },
  root_markers = { '.git' },
})

vim.lsp.enable('sqlls')
