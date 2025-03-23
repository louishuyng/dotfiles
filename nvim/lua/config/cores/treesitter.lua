local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then return end

require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    "go", "graphql", "javascript", "jsdoc", "http", "json", "jsonc", "lua",
    "python", "ruby", "rust", "tsx", "typescript", "svelte", "kotlin", "yaml",
    "html", "toml", "vim", "fish", "bash", "markdown", "terraform", "smithy",
    "regex", "markdown_inline", "vimdoc", "xml", "ocaml", "zig", "gleam", "kdl", "sql",
  },
  matchup = { enable = true },
  autotag = { enable = true },
  context_commentstring = { enable = true, },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
}
