vim.lsp.config('smithy_ls', {
  cmd = { 'smithy-language-server' },
  filetypes = { 'smithy' },
  root_markers = { 'smithy-build.json', 'build.gradle', 'build.gradle.kts', '.git' },
})

vim.lsp.enable('smithy_ls')
