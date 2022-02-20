local M = {}

M.init = function(theme)
   if not theme then
      theme = 'chadracula'
   end

   vim.g.nvchad_theme = theme

   local present, base16 = pcall(require, "base16")

   if present then
      -- first load the base16 theme
      base16(base16.themes(theme), true)

      -- unload to force reload
      package.loaded["config.colors.highlights" or false] = nil
      -- then load the highlights
      require "config.colors.highlights"
   end
end

M.get = function(theme)
   if not theme then
      theme = vim.g.nvchad_theme
   end

   return require("hl_themes." .. theme)
end

return M
