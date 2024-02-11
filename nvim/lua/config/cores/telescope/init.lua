local present, telescope = pcall(require, "telescope")
local actions = require 'telescope.actions'

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
    wrap_results = true,
    sorting_strategy = "ascending",
    winblend = 0,
    pickers = {
      diagnostics = {
        theme = "ivy",
        initial_mode = "normal",
        layout_config = {preview_cutoff = 9999}
      }
    },
    border = {},
    borderchars = {
      prompt = {" ", " ", "─", " ", " ", " ", "─", "─"},
      results = {"─", " ", " ", " ", "─", "─", " ", " "},
      preview = {"─", " ", "─", "│", "┬", "─", "─", "╰"}
    },
    layout_strategy = 'bottom_pane',
    layout_config = {
      height = 0.3,
      preview_width = 0.5,
      prompt_position = "bottom"
    },
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-b>"] = actions.preview_scrolling_up,
        ["<C-f>"] = actions.preview_scrolling_down,
        ["<C-v>"] = actions.select_vertical,
        ["<C-s>"] = actions.select_horizontal,
        ["<c-d>"] = actions.delete_buffer
      }
    },
    extensions = {
      file_browser = {
        theme = "dropdown",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true
      }
    }
  }
}

telescope.load_extension('harpoon')
telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("refactoring")
telescope.load_extension("live_grep_args")
