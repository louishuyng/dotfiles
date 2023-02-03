local present, telescope = pcall(require, "telescope")
local actions = require 'telescope.actions'
local icons = require("nvim-nonicons")

telescope.setup {
  defaults = {
    file_ignore_patterns = {
      ".git/", ".cache", "%.o", "%.a", "%.out", "%.class", "%.pdf", "%.mkv",
      "%.mp4", "%.zip"
    },
    vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename", "--line-number",
      "--column", "--smart-case"
    },
    prompt_prefix = "  " .. icons.get("telescope") .. "  ",
    selection_caret = " ❯ ",
    entry_prefix = "   ",
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
    layout_config = {height = 0.8, prompt_position = "top"},
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
    }
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case" -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
  }
}

telescope.load_extension('fzf')
telescope.load_extension("flutter")
