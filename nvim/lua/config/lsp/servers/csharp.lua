vim.lsp.config('csharp_ls', {
  cmd = { 'csharp-ls' },
  filetypes = { 'cs' },
  root_markers = { '*.sln', '*.csproj', 'omnisharp.json', 'function.json', '.git' },
})

vim.lsp.enable('csharp_ls')
