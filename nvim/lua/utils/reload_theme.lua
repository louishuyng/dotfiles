local M = {}

M.reload_theme = function()
  vim.cmd([[
          luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
          luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
          luafile ~/.dotfiles/nvim/lua/ui/buffer.lua
      ]])
end

return M
