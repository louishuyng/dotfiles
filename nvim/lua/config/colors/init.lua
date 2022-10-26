local M = {}

M.init = function()
  vim.cmd('colorscheme nightfox')

  package.loaded["config.colors.highlights" or false] = nil
  -- then load the highlights
  require "config.colors.highlights"
end

M.get = function(theme)
  if not theme then theme = vim.g.nvchad_theme end

  return require("hl_themes." .. theme)
end

return M
