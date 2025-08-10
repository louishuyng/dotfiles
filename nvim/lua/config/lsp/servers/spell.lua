vim.lsp.config('typos_lsp', {
  cmd = { 'typos-lsp' },
  filetypes = { 'text', 'markdown', 'tex', 'gitcommit' },
  root_markers = { '.git' },
})

vim.lsp.enable('typos_lsp')
