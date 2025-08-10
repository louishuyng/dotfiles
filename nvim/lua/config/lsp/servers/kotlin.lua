vim.lsp.config('kotlin_language_server', {
  cmd = { 'kotlin-language-server' },
  filetypes = { 'kotlin' },
  root_markers = { 'settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts', '.git' },
})

vim.lsp.enable('kotlin_language_server')
