local on_attach = require 'config/lsp/on_attach'

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.cbfmt,
    null_ls.builtins.formatting.protolint,
    null_ls.builtins.formatting.ocamlformat,
    null_ls.builtins.formatting.yamlfmt, null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.protolint,
    null_ls.builtins.diagnostics.cfn_lint
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true
    on_attach(client, bufnr)
  end
})
