require 'config/lsp/rename'

-- Highlight line numbers for diagnostics
vim.fn.sign_define('DiagnosticSignError',
                   {numhl = 'LspDiagnosticsLineNrError', text = ''})
vim.fn.sign_define('DiagnosticSignWarn',
                   {numhl = 'LspDiagnosticsLineNrWarning', text = ''})
vim.fn.sign_define('DiagnosticSignInfo', {text = ''})
vim.fn.sign_define('DiagnosticSignHint', {text = ''})

require("mason").setup()

local ensure_installed = {
  "lua_ls", "rust_analyzer", "kotlin_language_server", "eslint", "tsserver",
  "bashls", "cssls", "denols", "pyright", "solargraph", "svelte", "terraformls",
  "rnix-lsp", "prettierd", "rubocop", "codespell", "cfn_lint", "yamlfmt",
  "smithy-language-server", "yamlls"
}

require("mason-null-ls").setup {ensure_installed = ensure_installed}

require "config/lsp/golang"
require "config/lsp/kotlin"
require "config/lsp/lua"
require "config/lsp/nix"
require "config/lsp/null_ls"
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
