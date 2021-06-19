local g =vim.g

g.nvim_tree_side = "left"
g.nvim_tree_ignore = {".git", "node_modules", ".cache"}
g.nvim_tree_auto_open = 0
g.nvim_tree_follow = 1
g.nvim_tree_indent_markers = 1
g.nvim_tree_git_hl = 1
g.nvim_tree_root_folder_modifier = ":t"
g.nvim_tree_allow_resize = 1
g.nvim_tree_update_cwd = 0 

g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1
}

g.nvim_tree_icons = {
    default = " ",
    symlink = " ",
    git = {
        unstaged = "✗",
        staged = "✓",
        unmerged = "",
        renamed = "➜",
        untracked = "★",
        deleted = "",
        ignored = "◌"
    },
    folder = {
        default = "",
        open = "",
        symlink = "",
        empty = "",
        empty_open = "",
        symlink_open = ""
    }
}

local tree_cb = require "nvim-tree.config".nvim_tree_callback

g.nvim_tree_bindings = {
    ["u"] = ":lua require'some_module'.some_function()<cr>",

    -- default mappings
    ["<CR>"] = tree_cb("edit"),
    ["o"] = tree_cb("edit"),
    ["C"] = tree_cb("cd"),
    ["s"] = tree_cb("vsplit"),
    ["i"] = tree_cb("split"),
    ["t"] = tree_cb("tabnew"),
    ["<"] = tree_cb("prev_sibling"),
    [">"] = tree_cb("next_sibling"),
    ["<BS>"] = tree_cb("close_node"),
    ["<S-CR>"] = tree_cb("close_node"),
    ["<Tab>"] = tree_cb("preview"),
    ["I"] = tree_cb("toggle_ignored"),
    ["H"] = tree_cb("toggle_dotfiles"),
    ["R"] = tree_cb("refresh"),
    ["a"] = tree_cb("create"),
    ["d"] = tree_cb("remove"),
    ["r"] = tree_cb("rename"),
    ["x"] = tree_cb("cut"),
    ["c"] = tree_cb("copy"),
    ["p"] = tree_cb("paste"),
    ["y"] = tree_cb("copy_name"),
    ["Y"] = tree_cb("copy_path"),
    ["gy"] = tree_cb("copy_absolute_path"),
    ["[h"] = tree_cb("prev_git_item"),
    ["]h"] = tree_cb("next_git_item"),
    ["u"] = tree_cb("dir_up"),
    ["q"] = tree_cb("close")
} 
