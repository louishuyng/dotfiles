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
      sorting_strategy = "ascending",
      winblend = 20,
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
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case"
      },
      initial_mode = "insert",
      selection_strategy = "reset",
      layout_strategy = "horizontal",
      layout_config = {
          horizontal = {
            prompt_position = "top",
          },
          vertical = {
            mirror = false
          },
        },
      },
    }
end

return M
