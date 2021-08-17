local M = {}

local opts = {noremap = true, silent = true}
local icons = require "nvim-nonicons"

M.config = function()
  local actions = require('telescope.actions')
  require("telescope").setup {
    defaults = {
      prompt_prefix = "  " .. icons.get("telescope") .. "  ",
      selection_caret = " ❯ ",
      entry_prefix = "   ",
      scroll_strategy = nil,
      sorting_strategy = 'ascending',
      winblend = 0,
      mappings = {
          i = {
              ["<C-d>"] = actions.close,
              ["<Esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_vertical,
              ["<C-i>"] = actions.select_horizontal,
          },
          n = {
              ["<C-d>"] = actions.close,
              ["<Esc>"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-s>"] = actions.select_vertical,
              ["<C-i>"] = actions.select_horizontal,
          }
      },
      layout_config = {
        preview_height = 20,
        vertical = { width = 0.4, height = 0.7, mirror = true }
      },
      initial_mode = "insert",
      layout_strategy = "vertical",
    },
  }
end

return M
