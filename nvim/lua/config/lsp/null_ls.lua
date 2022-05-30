local on_attach = require 'config/lsp/on_attach'

local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.lua_format,
    null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.rubocop, null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.diagnostics.tsc
  },
  on_attach = on_attach 
})
