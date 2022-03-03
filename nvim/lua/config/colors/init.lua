local M = {}

M.init = function(theme)
   if not theme then
      theme = 'chadracula'
   end

   vim.g.nvchad_theme = theme

   local present, base16 = pcall(require, "base16")

   if present then
      -- first load the base16 custom theme
      local custom_theme = base16.theme_from_array {
	"0d0d0d"; "404040"; "606060"; "6f6f6f";
	"808080"; "dcdccc"; "c0c0c0"; "dcdccc";
	"caa450"; "caa450"; "caa450"; "c35fb2";
	"dcdccc"; "8579c5"; "55b5a4"; "dcdccc";
      }

      base16(custom_theme, true)

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
