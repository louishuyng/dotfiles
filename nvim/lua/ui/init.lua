-- Check if the mode in Macos is darkmode or lightmode then set background accordingly
-- Run loop after 5 minutes to check if the mode has changed
local timer = vim.loop.new_timer()
local sleep = 60 * 5 * 1000

local function check_mode()
  local hasChanged = false

  if vim.fn.system("defaults read -g AppleInterfaceStyle") == "Dark\n" then
    if not vim.g.dark_mode then
      hasChanged = true
      vim.g.dark_mode = true
    end

  else
    if vim.g.dark_mode then
      hasChanged = true
      vim.g.dark_mode = false
    end
  end

  if hasChanged then
    vim.cmd([[
    luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
    luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
  ]])
  end
end

timer:start(0, sleep, vim.schedule_wrap(function() check_mode() end))

require "ui/colorscheme"
require "ui/dashboard"
require "ui/statusline"
