vim.lsp.config('htmx', {
  cmd = { 'htmx-lsp' },
  filetypes = { 'html' },
  root_markers = { '.git' },
  single_file_support = false,
})

vim.lsp.enable('htmx')
