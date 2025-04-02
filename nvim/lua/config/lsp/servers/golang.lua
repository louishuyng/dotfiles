local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.gopls.setup({
  on_attach = on_attach,
})

lsp_config.golangci_lint_ls.setup({
  on_attach = on_attach,
})
