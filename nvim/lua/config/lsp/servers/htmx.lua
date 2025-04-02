local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.htmx.setup({
  on_attach = on_attach,
  single_file_support = false,
})
