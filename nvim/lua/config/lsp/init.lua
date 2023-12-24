require("mason").setup()

local ensure_installed = {
  "lua_ls", "rust_analyzer", "kotlin_language_server", "eslint", "tsserver",
  "bashls", "cssls", "denols", "pyright", "solargraph", "svelte", "terraformls",
  "rnix-lsp", "prettierd", "rubocop", "codespell", "cfn_lint", "yamlfmt",
  "smithy-language-server", "yamlls", "ltex-ls", "ruby-lsp", "ocaml-lsp",
  "ocamlformat", "gopls"
}

require("mason-null-ls").setup {ensure_installed = ensure_installed}

require "config/lsp/golang"
require "config/lsp/kotlin"
require "config/lsp/ltex"
require "config/lsp/lua"
require "config/lsp/nix"
require "config/lsp/null_ls"
require "config/lsp/ocaml"
require "config/lsp/python"
require "config/lsp/ruby"
require "config/lsp/rust"
require "config/lsp/smithy"
require "config/lsp/svelte"
require "config/lsp/terraform"
require "config/lsp/typescript"
require "config/lsp/yamlls"

-- require "config/lsp/bash"
-- require "config/lsp/css"
-- require "config/lsp/sql"
-- require('config/lsp/deno')

-- Highlight line numbers for diagnostics
local signs = {Error = " ", Warn = " ", Hint = "💡", Info = " "}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

vim.cmd([[
   hi DiagnosticSignError guifg=#e06c75
   hi DiagnosticSignWarn guifg=#e5c07b
   hi DiagnosticSignInfo guifg=#61afef
   hi DiagnosticSignHint guifg=#98c379
]])

-- vim.keymap.set("n", "[d", ":Lspsaga diagnostic_jump_prev<CR>", bufopts)
-- vim.keymap.set("n", "]d", ":Lspsaga diagnostic_jump_next<CR>", bufopts)

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
               {desc = "Go to previous diagnostic"})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next,
               {desc = "Go to next diagnostic"})
