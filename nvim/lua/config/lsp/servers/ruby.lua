vim.lsp.config('solargraph', {
  settings = { solargraph = { diagnostics = true } },
})

vim.lsp.enable('solargraph')
