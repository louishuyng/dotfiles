local M = {}

M.reload_theme = function()
  vim.cmd([[
          luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
          luafile ~/.dotfiles/nvim/lua/ui/colorful_statusline.lua
          luafile ~/.dotfiles/nvim/lua/ui/buffer.lua
          luafile ~/.dotfiles/nvim/lua/plugins/ui.lua
      ]])
end

return M
