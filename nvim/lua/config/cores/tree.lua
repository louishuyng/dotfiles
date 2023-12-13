require("nvim-tree").setup({
  update_focused_file = {enable = true, update_cwd = false},
  git = {enable = true},
  renderer = {
    root_folder_modifier = ":t",
    icons = {
      git_placement = "after",
      show = {
        file = true,
        folder = false,
        folder_arrow = true,
        git = true,
        modified = true
      },
      glyphs = {
        git = {
          unstaged = "",
          staged = "",
          unmerged = "",
          renamed = "➜",
          untracked = "+",
          deleted = "",
          ignored = "◌"
        }
      }
    }
  },
  diagnostics = {enable = false},
  view = {
    side = 'right',
    width = 30,
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
  }
})
