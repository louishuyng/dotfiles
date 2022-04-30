local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then
  return
end

ts_config.setup {
  ensure_installed = {
    "go",
    "graphql",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "python",
    "ruby",
    "rust",
    "tsx",
    "typescript",
    "yaml",
    "html",
    "toml",
    "vim",
    "norg",
    "markdown"
  },
  matchup = {
    enable = true
  },
  highlight = {
    enable = true,
    disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental),
    additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  autotag = {
    enable = true
  },
  indent = {
    enable = true
  },
  context_commentstring = {
    enable = true
  },
}
