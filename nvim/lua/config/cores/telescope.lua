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
      selection_caret = "  ",
      entry_prefix = "  ",
      sorting_strategy = 'ascending',
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      winblend = 0,
      border = {},
      borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
      color_devicons = true,
      use_less = true,
      set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
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
      layout_strategy = "vertical",
      layout_config = {
        width = 0.95,
        height = 0.85,
        -- preview_cutoff = 120,
        prompt_position = "top",

        horizontal = {
          preview_width = function(_, cols, _)
            if cols > 200 then
              return math.floor(cols * 0.4)
            else
              return math.floor(cols * 0.6)
            end
          end
        },
        vertical = {width = 0.7, height = 0.8, preview_height = 0.5},
        flex = {horizontal = {preview_width = 0.9}}
      }
    },
    extensions = {
      ["ui-select"] = {require("telescope.themes").get_dropdown {}},
      fzy_native = {override_generic_sorter = true, override_file_sorter = true},
      project = {
        base_dirs = {
          {'~/Dev/Projects/Productpine'}, {'~/Dev/Projects/Eatiplan'},
          {'~/Dev/Projects/Oivan/sakani-workspace'}, {'~/.dotfiles'}
        }
      }
    }
  }

  require'telescope'.load_extension('project')
  require("telescope").load_extension("ui-select")
  require("telescope").load_extension("flutter")
end

return M
