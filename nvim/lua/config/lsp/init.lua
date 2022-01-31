vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    underline = true,
    virtual_text = {
      prefix = "●",
      spacing = 2,
    },
    update_in_insert = true,
    severity_sort = true,
  }
)

local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Information = " "
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

-- require('lsp/deno')
require "config/lsp/angular"
require "config/lsp/bash"
require "config/lsp/css"
require "config/lsp/dart"
require "config/lsp/eslint"
require "config/lsp/golang"
require "config/lsp/json"
require "config/lsp/lua"
require "config/lsp/null_ls"
require "config/lsp/ruby"
require "config/lsp/rust"
require "config/lsp/sql"
require "config/lsp/typescript"
require "config/lsp/vim"
