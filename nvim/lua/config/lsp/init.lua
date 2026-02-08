require('config.lsp.diagnostic')
require('config.lsp.lint')
require('config.lsp.on_attach')
require('config.lsp.performance')
require('config.lsp.register_formatters')
require('config.lsp.register_server')

require('mason').setup({
  ensure_installed = {
    -- Lua
    'lua-language-server',
    'stylua',

    -- Rust
    'rust_analyzer',

    -- Ruby (only solargraph, ruby-lsp not used)
    'solargraph',
    'rubocop',

    -- Gleam
    -- 'gleam',

    -- Golang
    'gopls',
    'golangci-lint-langserver',
    'goimports',
    'delve',

    -- Elixir
    'elixirls',

    --Zig
    -- 'zls',

    --Ocaml
    -- 'ocaml-lsp',
    -- 'ocamlformat',

    -- Kotlin
    -- 'kotlin_language_server',

    -- CSharp
    -- 'csharp-language-server',

    -- Typescript
    'vtsls',
    'eslint',
    'prettier',
    'js-debug-adapter',

    -- Python
    -- 'pyright',

    -- Nix
    -- 'rnix-lsp',

    -- Terraform
    -- 'terraform-ls',
    -- 'terraformls',

    -- HTML
    -- 'htmx-lsp',
    -- 'html-lsp',
    'cssls',

    -- Others
    'bashls',
    'codespell',
    'cfn_lint',
    'yamlfmt',
    'smithy-language-server',
    'yaml-language-server',
    'json-lsp',

    -- Spell Check
    'typos-lsp',
  },
})
