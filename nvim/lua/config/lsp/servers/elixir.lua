vim.lsp.config('elixirls', {
  cmd = { 'elixir-ls' },
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  root_markers = { 'mix.exs', '.git' },
})

vim.lsp.enable('elixirls')
