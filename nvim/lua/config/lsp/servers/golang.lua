local lsp_config = require 'lspconfig'

lsp_config.gopls.setup({
  settings = {
    gopls = {
      hints = {
        rangeVariableTypes = true,
        parameterNames = true,
        constantValues = true,
        assignVariableTypes = false,
        compositeLiteralFields = false,
        compositeLiteralTypes = false,
        functionTypeParameters = true,
      },
    },
  },
})

lsp_config.golangci_lint_ls.setup({})
