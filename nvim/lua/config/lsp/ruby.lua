local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.solargraph.setup({
  on_attach = function(client)
    client.server_capabilities.document_formatting = true
    on_attach(client)
  end
})
