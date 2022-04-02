local M = {}

M.init = function(theme)
   vim.g.oceanic_material_transparent_background = 1
   vim.cmd("colorscheme oceanic_material")

   if not theme then
      theme = 'onedark'
   end

   vim.g.nvchad_theme = theme

  -- unload to force reload
  package.loaded["config.colors.highlights" or false] = nil
  -- then load the highlights
  require "config.colors.highlights"
end

M.get = function(theme)
   if not theme then
      theme = vim.g.nvchad_theme
   end

   return require("hl_themes." .. theme)
end

return M
