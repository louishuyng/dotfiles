vim.lsp.config('solargraph', {
  cmd = { 'solargraph', 'stdio' },
  filetypes = { 'ruby' },
  root_markers = { 'Gemfile', '.git' },
  settings = { solargraph = { diagnostics = true } },
})

vim.lsp.enable('solargraph')
