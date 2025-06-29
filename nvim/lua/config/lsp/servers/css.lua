local lsp_config = require 'lspconfig'

lsp_config.cssls.setup({
  filetypes = { 'css', 'sass', 'scss' },
  settings = {
    css = { validate = true },
    sass = { validate = true },
    scss = { validate = true },
  },
})
