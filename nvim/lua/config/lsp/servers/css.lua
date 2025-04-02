local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.cssls.setup({
  filetypes = { 'css', 'sass', 'scss' },
  settings = {
    css = { validate = true },
    sass = { validate = true },
    scss = { validate = true },
  },
  on_attach = on_attach,
})
