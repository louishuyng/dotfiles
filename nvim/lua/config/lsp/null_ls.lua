local on_attach = require 'config/lsp/on_attach'

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.lua_format,
    null_ls.builtins.formatting.autopep8, null_ls.builtins.formatting.protolint,
    null_ls.builtins.diagnostics.codespell, null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.diagnostics.rubocop, null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.protolint,
    null_ls.builtins.code_actions.eslint_d
  },
  on_attach = function(client)
    client.server_capabilities.document_formatting = true
    on_attach(client)
  end
})
