local on_attach = require 'lsp/on_attach'

local null_ls = require("null-ls")null_ls.setup({
  sources = {
    null_ls.builtins.completion.spell,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.rubocop,
  },
  on_attach = on_attach
})
