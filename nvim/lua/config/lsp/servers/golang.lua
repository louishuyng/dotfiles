vim.lsp.config('gopls', {
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
vim.lsp.config('golangci_lint_ls', {})

vim.lsp.enable('gopls')
vim.lsp.enable('golangci_lint_ls')
