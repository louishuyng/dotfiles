vim.lsp.config('sourcekit', {
  filetypes = { 'swift' },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.enable('sourcekit')
