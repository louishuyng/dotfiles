local nonicons_extention = require("nvim-nonicons.extentions.nvim-tree")

require("nvim-tree").setup({
  auto_reload_on_write = false,
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {},
  open_on_tab = false,
  hijack_directories = {enable = true, auto_open = false},
  hijack_cursor = false,
  update_cwd = false,
  update_focused_file = {
    enable = true,
    update_cwd = false,
    ignore_list = {".git", "node_modules", ".cache"}
  },
  system_open = {cmd = nil, args = {}},
  filters = {dotfiles = false, custom = {}},
  git = {enable = false},
  diagnostics = {enable = false},
  view = {
    side = 'right',
    adaptive_size = true,
    mappings = {
      list = {
        {key = {"l", "<2-LeftMouse>"}, action = "edit"},
        {key = {"L", "<2-RightMouse>"}, action = "cd"},
        {key = "v", action = "vsplit"}, {key = "s", action = "split"},
        {key = "[h", action = "prev_git_item"},
        {key = "]h", action = "next_git_item"},
        {key = "h", action = "close_node"},
        {key = "<CR>", action = "system_open"}, {key = "v", action = "vsplit"},
        {key = 'H', action = "dir_up"}, {key = "s", action = "split"}
      }
    }
  },
  renderer = {
    group_empty = true,
    icons = {
      webdev_colors = true,
      git_placement = "before",
      padding = " ",
      symlink_arrow = " ➛ ",
      show = {file = true, folder = true, folder_arrow = true, git = true},
      glyphs = {
        default = "",
        symlink = "",
        folder = {
          arrow_closed = "",
          arrow_open = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = ""
        },
        git = {
          unstaged = "•",
          staged = "•",
          unmerged = "≠",
          renamed = "•",
          untracked = "•"
        }
      }
    }
  }
})
