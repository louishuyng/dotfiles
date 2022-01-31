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
    "vim"
  },
  matchup = {
    enable = true
  },
  highlight = {
    enable = true
  },
  autotag = {
    enable = true
  },
  indent = {
    enable = true
  },
  context_commentstring = {
    enable = true
  }
}
