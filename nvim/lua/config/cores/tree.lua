local api = require("nvim-tree.api")

require("nvim-tree").setup({
  update_focused_file = { enable = true, update_cwd = false },
  git = { enable = true },
  renderer = {
    root_folder_modifier = ":t",
    icons = {
      git_placement = "after",
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
        modified = true
      },
      glyphs = {
        bookmark = "",
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
  diagnostics = { enable = false },
  view = {
    width = 30,
    hide_root_folder = false,
    side = 'right',
    number = false,
    relativenumber = false,
    adaptive_size = true,
    mappings = {
      list = {
        { key = { "l", "<2-LeftMouse>" },  action = "edit" },
        { key = { "L", "<2-RightMouse>" }, action = "cd" },
        { key = "v",                       action = "vsplit" }, { key = "s", action = "split" },
        { key = "[h",   action = "prev_git_item" },
        { key = "]h",   action = "next_git_item" },
        { key = "h",    action = "close_node" },
        { key = "<CR>", action = "system_open" }, { key = "v", action = "vsplit" },
        { key = 'H', action = "dir_up" }, { key = "s", action = "split" }, {
        key = "yy",
        action = "copy files",
        action_cb = function()
          local marks = api.marks.list()
          if #marks == 0 then
            table.insert(marks, api.tree.get_node_under_cursor())
          end
          for _, node in pairs(marks) do api.fs.copy.node(node) end
          api.marks.clear()
          api.tree.reload()
        end
      }, {
        key = "dd",
        action = "cut files",
        action_cb = function()
          local marks = api.marks.list()
          if #marks == 0 then
            table.insert(marks, api.tree.get_node_under_cursor())
          end
          for _, node in pairs(marks) do api.fs.cut(node) end
          api.marks.clear()
          api.tree.reload()
        end
      }, {
        key = "df",
        action = "trash files",
        action_cb = function()
          local marks = api.marks.list()
          if #marks == 0 then
            table.insert(marks, api.tree.get_node_under_cursor())
          end
          vim.ui.input({
            prompt = string.format("Trash %s files? [y/n] ", #marks)
          }, function(input)
            if input == "y" then
              for _, node in ipairs(marks) do
                api.fs.trash(node)
              end
              api.marks.clear()
              api.tree.reload()
            end
          end)
        end
      }, {
        key = "dF",
        action = "remove files",
        action_cb = function()
          local marks = api.marks.list()
          if #marks == 0 then
            table.insert(marks, api.tree.get_node_under_cursor())
          end
          vim.ui.input({
            prompt = string.format("Remove/Delete %s files? [y/n] ", #marks)
          }, function(input)
            if input == "y" then
              for _, node in ipairs(marks) do
                api.fs.remove(node)
              end
              api.marks.clear()
              api.tree.reload()
            end
          end)
        end
      }, {
        key = "p",
        action = "paste files",
        action_cb = function()
          api.fs.paste()
          api.tree.reload()
        end
      }, {
        key = "M",
        action = "clear all marks",
        action_cb = function()
          api.marks.clear()
          api.tree.reload()
        end
      }
      }
    }
  }
})
