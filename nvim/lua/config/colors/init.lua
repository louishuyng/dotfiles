local M = {}

M.init = function(theme)
  vim.cmd("colorscheme industry")

  if not theme then theme = 'onedark' end

  vim.g.nvchad_theme = theme

  -- unload to force reload
  package.loaded["config.colors.highlights" or false] = nil
  -- then load the highlights
  require "config.colors.highlights"
end

M.get = function(theme)
  if not theme then theme = vim.g.nvchad_theme end

  return require("hl_themes." .. theme)
end

return M
