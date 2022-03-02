local present, nvimtree = pcall(require, "nvim-tree")
local tree_cb = require('nvim-tree.config').nvim_tree_callback

if not present then
   return
end

local g = vim.g

vim.o.termguicolors = true

g.nvim_tree_add_trailing = 0
g.nvim_tree_git_hl = 1
g.nvim_tree_gitignore = 0
g.nvim_tree_hide_dotfiles = 0
g.nvim_tree_highlight_opened_files = 0
g.nvim_tree_indent_markers = 1
g.nvim_tree_ignore = { ".git", "node_modules", ".cache" }
g.nvim_tree_quit_on_open = 0
g.nvim_tree_root_folder_modifier = table.concat { ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" }
--
g.nvim_tree_show_icons = {
   folders = 1,
   folder_arrows = 1,
   files = 1,
   git = 1,
}

g.nvim_tree_icons = {
  default = "",
  folder = {
      default = "",
      empty = "",
      empty_open = "",
      open = "",
      symlink = "",
      symlink_open = "",
  },
  symlink = "",
  git = {
    deleted = "",
    ignored = "◌",
    renamed = "➜",
    staged = "✓",
    unmerged = "",
    unstaged = "✗",
    untacked = "★",
  },
  lsp = {
    error = " ",
    warning = " ",
    hint = " ",
    info = " "
  }
}

nvimtree.setup {
  disable_netrw = true,
  hijack_netrw = true,
  ignore_ft_on_setup = { "dashboard" },
  auto_close = false,
  open_on_tab = false,
  hijack_cursor = true,
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = false,
  },
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  view = {
    allow_resize = true,
    side = "left",
    width = 25,
    mappings = {
      list = {
        { key = {"<CR>", "o", "<2-LeftMouse>"}, cb = tree_cb("edit") },
        { key = {"<2-RightMouse>", "<C-}>"},    cb = tree_cb("cd") },
        { key = "s",                            cb = tree_cb("vsplit") },
        { key = "i",                            cb = tree_cb("split") },
        { key = "t",                            cb = tree_cb("tabnew") },
        { key = "<",                            cb = tree_cb("prev_sibling") },
        { key = ">",                            cb = tree_cb("next_sibling") },
        { key = "u",                            cb = tree_cb("parent_node") },
        { key = "<BS>",                         cb = tree_cb("close_node") },
        { key = "<S-CR>",                       cb = tree_cb("close_node") },
        { key = "<Tab>",                        cb = tree_cb("preview") },
        { key = "K",                            cb = tree_cb("first_sibling") },
        { key = "J",                            cb = tree_cb("last_sibling") },
        { key = "I",                            cb = tree_cb("toggle_ignored") },
        { key = "H",                            cb = tree_cb("toggle_dotfiles") },
        { key = "R",                            cb = tree_cb("refresh") },
        { key = "a",                            cb = tree_cb("create") },
        { key = "d",                            cb = tree_cb("remove") },
        { key = "r",                            cb = tree_cb("rename") },
        { key = "<C->",                         cb = tree_cb("full_rename") },
        { key = "x",                            cb = tree_cb("cut") },
        { key = "c",                            cb = tree_cb("copy") },
        { key = "p",                            cb = tree_cb("paste") },
        { key = "y",                            cb = tree_cb("copy_name") },
        { key = "Y",                            cb = tree_cb("copy_path") },
        { key = "gy",                           cb = tree_cb("copy_absolute_path") },
        { key = "[h",                           cb = tree_cb("prev_git_item") },
        { key = "}h",                           cb = tree_cb("next_git_item") },
        { key = "u",                            cb = tree_cb("dir_up") },
        { key = "q",                            cb = tree_cb("close") },
        { key = "g?",                           cb = tree_cb("toggle_help") },
      }
    }
  },
}
