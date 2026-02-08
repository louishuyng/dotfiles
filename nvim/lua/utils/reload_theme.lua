local M = {}

M.reload_theme = function()
  -- Reload UI files
  vim.cmd([[
          luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
          luafile ~/.dotfiles/nvim/lua/ui/winbar.lua
      ]])
end

return M
