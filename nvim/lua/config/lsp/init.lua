require("mason").setup()

local ensure_installed = {
  -- Lua
  "lua_ls",
  "luaformatter",

  -- Rust
  "rust_analyzer",

  -- Ruby
  "solargraph",
  "rubocop",
  "ruby-lsp",

  -- Gleam
  "gleam",

  -- Golang
  "gopls",
  "golangci-lint",
  "golangci-lint-langserver",

  --Zig
  "zls",

  --Ocaml
  "ocaml-lsp",
  "ocamlformat",

  -- Kotlin
  "kotlin_language_server",

  -- CSharp
  "csharp-language-server",

  -- Typescript
  "ts_ls",
  "typescript-language-server",
  "eslint-lsp",
  "prettier",
  "svelte",
  "denols",
  "biome",

  -- Python
  "pyright",

  -- Nix
  "rnix-lsp",

  -- Terraform
  "terraform-ls",
  "terraformls",

  -- HTML / CSS
  "htmx-lsp",
  "html-lsp",
  "cssls",

  -- Others
  "bashls", "codespell", "cfn_lint", "yamlfmt", "smithy-language-server", "yamlls",
  "ltex-ls", "yaml-language-server", "json-lsp",

  -- Spell Check
  "typos-lsp"
}

require("mason-null-ls").setup { ensure_installed = ensure_installed }

require "config/lsp/csharp"
require "config/lsp/gleam"
require "config/lsp/golang"
require "config/lsp/html"
require "config/lsp/htmx"
require "config/lsp/json"
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
require "config/lsp/spell"
require "config/lsp/svelte"
require "config/lsp/terraform"
require "config/lsp/typescript"
require "config/lsp/yamlls"
require "config/lsp/zig"

-- require "config/lsp/bash"
-- require "config/lsp/css"
-- require "config/lsp/sql"
-- require('config/lsp/deno')

-- Highlight line numbers for diagnostics
local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local bufopts = { buffer = true, silent = true }

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
  { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next,
  { desc = "Go to next diagnostic" })

vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
vim.lsp.handlers['textDocument/signatureHelp'] =
    vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = "single" })
