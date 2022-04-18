local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.gopls.setup({
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = true
    on_attach(client)
  end
})
