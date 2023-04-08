require("mason").setup()

local ensure_installed = {
  "lua_ls", "rust_analyzer", "kotlin_language_server", "eslint", "tsserver",
  "bashls", "cssls", "denols", "pyright", "solargraph", "svelte", "terraformls",
  "yamlls", "prettierd", "rubocop", "codespell"
}

require("mason-null-ls").setup {ensure_installed = ensure_installed}

-- require "config/lsp/bash"
-- require "config/lsp/css"
-- require "config/lsp/rust"
-- require "config/lsp/sql"
-- require('config/lsp/deno')
require "config/lsp/golang"
require "config/lsp/kotlin"
require "config/lsp/lua"
require "config/lsp/null_ls"
require "config/lsp/python"
require "config/lsp/ruby"
require "config/lsp/svelte"
require "config/lsp/terraform"
require "config/lsp/typescript"
require "config/lsp/yaml"
