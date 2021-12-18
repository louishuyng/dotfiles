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
require "lsp/angular"
require "lsp/bash"
require "lsp/css"
require "lsp/dart"
require "lsp/eslint"
require "lsp/golang"
require "lsp/json"
require "lsp/lua"
require "lsp/ruby"
require "lsp/rust"
require "lsp/sql"
require "lsp/typescript"
require "lsp/vim"
