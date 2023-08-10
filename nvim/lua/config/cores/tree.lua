require("nvim-tree").setup({
  update_focused_file = {
    enable = true,
    update_cwd = false,
    ignore_list = {".git", "node_modules", ".cache"}
  },
  system_open = {cmd = nil, args = {}},
  filters = {dotfiles = false, custom = {}},
  git = {enable = false},
  diagnostics = {enable = false},
  notify = {threshold = vim.log.levels.ERROR},
  renderer = {
    root_folder_label = function(path) return vim.fn.fnamemodify(path, ":t") end
  },
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
  }
})
