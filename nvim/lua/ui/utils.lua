local M = {}

local dark_theme = vim.g.default_black_theme
local light_theme = vim.g.default_white_theme

M.theme_by_system = function()
  -- Check if the mode in Macos is darkmode or lightmode then set background accordingly
  -- Run loop after 1 minute to check if the mode has changed
  local timer = vim.loop.new_timer()
  local sleep = 60 * 1 * 1000

  local function check_mode()
    local hasChanged = false

    if vim.fn.system("defaults read -g AppleInterfaceStyle") == "Dark\n" then
      if vim.g.theme == light_theme then
        hasChanged = true
      end

      vim.g.theme = dark_theme
    else
      if vim.g.theme == dark_theme then
        hasChanged = true
      end

      vim.g.theme = light_theme
    end

    if hasChanged then
      vim.cmd([[
      luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
      luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
      luafile ~/.dotfiles/nvim/lua/plugins/ui.lua
    ]])
    end
  end

  timer:start(0, sleep, vim.schedule_wrap(function() check_mode() end))
  check_mode()
end

return M
