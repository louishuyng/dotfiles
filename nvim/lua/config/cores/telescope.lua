local M = {}

M.config = function()
  local actions = require 'telescope.actions'
  require("telescope").setup {
    defaults = {
      file_ignore_patterns = {
        ".git/", ".cache", "%.o", "%.a", "%.out", "%.class", "%.pdf", "%.mkv",
        "%.mp4", "%.zip"
      },
      vimgrep_arguments = {
        "rg", "--color=never", "--no-heading", "--with-filename",
        "--line-number", "--column", "--smart-case"
      },
      prompt_prefix = '   ',
      selection_caret = '  ',
      entry_prefix = '   ',
      path_display = {'truncate'},
      sorting_strategy = 'ascending',
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      winblend = 0,
      border = {},
      borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
      color_devicons = true,
      use_less = true,
      set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
      initial_mode = "insert",
      mappings = {
        i = {
          ["<C-d>"] = actions.close,
          ["<Esc>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-b>"] = actions.preview_scrolling_up,
          ["<C-f>"] = actions.preview_scrolling_down,
          ["<C-v>"] = actions.select_vertical,
          ["<C-s>"] = actions.select_horizontal
        }
      },
      layout_config = {vertical = {preview_height = 0.5}},
      layout_strategy = "vertical"
    },
    extensions = {
      fzy_native = {override_generic_sorter = true, override_file_sorter = true}
    }
  }

  require('telescope').load_extension('fzy_native')
  require("telescope").load_extension("flutter")
end

return M
