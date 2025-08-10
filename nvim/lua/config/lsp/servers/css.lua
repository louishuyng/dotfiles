vim.lsp.config('cssls', {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'sass', 'scss' },
  root_markers = { 'package.json', '.git' },
  settings = {
    css = { validate = true },
    sass = { validate = true },
    scss = { validate = true },
  },
})

vim.lsp.enable('cssls')
