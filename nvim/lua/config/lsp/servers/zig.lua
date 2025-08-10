vim.lsp.config('zls', {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'build.zig', '.git' },
})

vim.lsp.enable('zls')
