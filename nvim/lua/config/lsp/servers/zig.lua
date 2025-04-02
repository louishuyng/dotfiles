local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.zls.setup({
  on_attach = on_attach,
})
