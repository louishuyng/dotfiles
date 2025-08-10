require('config.lsp.performance')
require('config.lsp.register_server')
require('config.lsp.register_formatters')
require('config.lsp.diagnostic')
require('config.lsp.on_attach')

require('mason').setup({
  ensure_installed = {
    -- Lua
    'lua-language-server',
    'stylua',

    -- Rust
    'rust_analyzer',

    -- Ruby
    'solargraph',
    'rubocop',
    'ruby-lsp',

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
    'ts_ls',
    'typescript-language-server',
    'js-debug-adapter',
    'eslint-lsp',
    'prettier',
    'denols',

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
    'yamlls',
    'ltex-ls',
    'yaml-language-server',
    'json-lsp',

    -- Spell Check
    'typos-lsp',
  },
})
