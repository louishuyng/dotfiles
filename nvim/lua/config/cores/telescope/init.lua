local _, telescope = pcall(require, "telescope")
local lga_actions = require("telescope-live-grep-args.actions")
local actions = require 'telescope.actions'

telescope.setup {
  defaults = {
    file_ignore_patterns = {
      ".git/",
    },
    vimgrep_arguments = {
      "rg",
      "--hidden",
      "-L",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    wrap_results = true,
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-b>"] = actions.preview_scrolling_up,
        ["<C-f>"] = actions.preview_scrolling_down,
        ["<C-v>"] = actions.select_vertical,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-d>"] = actions.delete_buffer,
        ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
        ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
      }
    },
    pickers = {
      diagnostics = {
        theme = "ivy",
        initial_mode = "normal",
        layout_config = { preview_cutoff = 9999 }
      },
    },
    border = {},
    borderchars = {
      prompt = { " ", " ", "─", " ", " ", " ", "─", "─" },
      results = { "─", " ", " ", " ", "─", "─", " ", " " },
      preview = { "─", " ", "─", "│", "┬", "─", "─", "╰" }
    },
    layout_strategy = 'bottom_pane',
    layout_config = {
      height = 0.3,
      prompt_position = "bottom"
    },
    extensions = {
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      },
      file_browser = {
        theme = "dropdown",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true
      },
    },
    preview = {
      mime_hook = function(filepath, bufnr, opts)
        local is_image = function(filepath)
          local image_extensions = { 'png', 'jpg', 'svg' } -- Supported image formats
          local split_path = vim.split(filepath:lower(), '.', { plain = true })
          local extension = split_path[#split_path]
          return vim.tbl_contains(image_extensions, extension)
        end
        if is_image(filepath) then
          local term = vim.api.nvim_open_term(bufnr, {})
          local function send_output(_, data, _)
            for _, d in ipairs(data) do
              vim.api.nvim_chan_send(term, d .. '\r\n')
            end
          end
          vim.fn.jobstart(
            {
              'chafa', filepath -- Terminal image viewer command
            },
            { on_stdout = send_output, stdout_buffered = true, pty = true })
        else
          require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
        end
      end
    },
  }

}

telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("refactoring")
telescope.load_extension("live_grep_args")
telescope.load_extension("rest")
telescope.load_extension("git_worktree")
