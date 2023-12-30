local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.gopls.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true
    on_attach(client, bufnr)
  end
})

lsp_config.golangci_lint_ls.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true
    on_attach(client, bufnr)
  end
})
