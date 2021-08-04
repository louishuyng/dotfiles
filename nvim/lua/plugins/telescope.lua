local M = {}

M.config = function()
  local actions = require('telescope.actions')
  require("telescope").setup {
    defaults = {
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
        prompt_prefix = " 🔍 ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = 'ascending',
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8
            },
            vertical = {
                mirror = false
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = {},
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = {"absolute"},
        winblend = 0,
        border = {},
        borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        color_devicons = true,
        use_less = true,
        set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker
      },
      extensions = {
          fzf = {
              fuzzy = true, -- false will only do exact matching
              override_generic_sorter = false, -- override the generic sorter
              override_file_sorter = true, -- override the file sorter
              case_mode = "smart_case" -- or "ignore_case" or "respect_case"
              -- the default case_mode is "smart_case"
          },
          media_files = {
              filetypes = {"png", "webp", "jpg", "jpeg"},
              find_cmd = "rg" -- find command (defaults to `fd`)
          }
      }
    }
end

return M
