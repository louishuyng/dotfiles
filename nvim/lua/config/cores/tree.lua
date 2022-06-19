require("nvim-tree").setup({
  sort_by = "case_sensitive",
  update_focused_file = {enable = true},
  diagnostics = {enable = true},
  view = {
    side = 'right',
    adaptive_size = true,
    mappings = {
      list = {
        {key = {"o", "<2-LeftMouse>"}, action = "edit"},
        {key = {"L", "<2-RightMouse>"}, action = "cd"},
        {key = "v", action = "vsplit"}, {key = "s", action = "split"},
        {key = "[h", action = "prev_git_item"},
        {key = "]h", action = "next_git_item"}, {key = "u", action = "dir_up"},
        {key = "<CR>", action = "system_open"},
        {key = "v", action = "vsplit"}, {key = "s", action = "split"},
      }
    }
  },
  renderer = {group_empty = true},
  filters = {dotfiles = true}
})
