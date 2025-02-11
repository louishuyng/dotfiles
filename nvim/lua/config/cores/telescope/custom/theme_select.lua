local has_telescope, telescope = pcall(require, 'telescope')
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require('telescope.previewers')

local dropdown_theme = require("config.cores.telescope.theme").dropdown_theme

if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

local M = {}

local theme_list = {
  { value = 'base',      display = 'Base' },
  { value = 'paper',     display = 'Paper' },
  { value = 'solarized', display = 'Solarized' },
  { value = 'latte',     display = 'Latte' },
}

local function reloadColorscheme()
  vim.cmd([[
    luafile ~/.dotfiles/nvim/lua/ui/colorscheme.lua
    luafile ~/.dotfiles/nvim/lua/ui/statusline.lua
    luafile ~/.dotfiles/nvim/lua/plugins/ui.lua

    syntax on
  ]])
end

return function(opts)
  -- Choose theme in telescope picker
  -- If select a theme, then set vim.g.theme to the selected theme
  -- Then call reloadColorscheme()

  opts = opts or {}
  local search = opts.search or ''


  -- Use pickers with dropdown theme
  pickers.new(dropdown_theme("Theme"), {
    finder = finders.new_table {
      results = theme_list,
      entry_maker = function(entry)
        return {
          display = entry.display,
          value = entry.value,
          ordinal = entry.display,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        vim.g.theme = selection.value
        reloadColorscheme()
        actions.close(prompt_bufnr)
      end)

      return true
    end
  }):find()
end
