local M = {}

M.config = function()
  local actions = require 'telescope.actions'
  require("telescope").setup {
    defaults = {
      vimgrep_arguments = {
         "rg",
         "--color=never",
         "--no-heading",
         "--with-filename",
         "--line-number",
         "--column",
         "--smart-case",
      },
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",      sorting_strategy = 'ascending',
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      mappings = {
        i = {
          ["<C-d>"] = actions.close,
          ["<Esc>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-b>"] = actions.preview_scrolling_up,
          ["<C-f>"] = actions.preview_scrolling_down,
          ["<C-s>"] = actions.select_vertical,
          ["<C-i>"] = actions.select_horizontal,
        },
        n = {
          ["<C-d>"] = actions.close,
          ["<Esc>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-b>"] = actions.preview_scrolling_up,
          ["<C-f>"] = actions.preview_scrolling_down,
          ["<C-s>"] = actions.select_vertical,
          ["<C-i>"] = actions.select_horizontal,
        }
      },
      layout_config = {
        height = 0.5,
        width = 0.4,
      },
      initial_mode = "insert",
      layout_strategy = "flex",
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true,
      },
      project = {
        base_dirs = {
          '~/Dev/Projects',
          '~/Dev/Projects/Oivan/sakani-workspace',
          '~/.dotfiles'
        }
      }
    }
  }

  require'telescope'.load_extension('project')
  require'telescope'.load_extension('fzy_native')
end

return M
