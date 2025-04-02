local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.html.setup({
  on_attach = on_attach,
})
