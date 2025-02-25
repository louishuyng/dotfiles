local snacks = require('snacks')

snacks.setup {
  bigfile = { enabled = true },
  gitbrowse = { enabled = true },
  zen = { enabled = true },
  rename = { enabled = true },
  quickfile = { enabled = true },
  lazygit = {
    enabled = true,
    os = { editPreset = "nvim-remote" },
  },
  dashboard = {
    enabled = true,
    sections = {
      {
        icon = " ",
        desc = "Browse Repo",
        padding = 1,
        key = "b",
        action = function()
          Snacks.gitbrowse()
        end,
      },
      function()
        local in_git = Snacks.git.get_root() ~= nil
        local cmds = {
          {
            title = "Notifications",
            cmd = "gh notify -s -a -n5",
            action = function()
              vim.ui.open("https://github.com/notifications")
            end,
            key = "n",
            icon = " ",
            height = 5,
            enabled = true,
          },
          {
            title = "Open Issues",
            cmd = "gh issue list -L 3",
            key = "i",
            action = function()
              vim.fn.jobstart("gh issue list --web", { detach = true })
            end,
            icon = " ",
            height = 5,
          },
          {
            icon = " ",
            title = "Open PRs",
            cmd = "gh pr list -L 3",
            key = "P",
            action = function()
              vim.fn.jobstart("gh pr list --web", { detach = true })
            end,
            height = 5,
          },
          {
            icon = " ",
            title = "Git Status",
            cmd = "git --no-pager diff --stat -B -M -C",
            height = 5,
          },
        }
        return vim.tbl_map(function(cmd)
          return vim.tbl_extend("force", {
            section = "terminal",
            enabled = in_git,
            padding = 0,
            ttl = 30,
            indent = 3,
          }, cmd)
        end, cmds)
      end,
      { section = "startup" },
    }
  },
}

-- Key bindings
vim.keymap.set("n", "<C-w>o", ":lua require('snacks').zen() <CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>go", ":lua require('snacks').gitbrowse() <CR>", { desc = "Open git browser url" })
vim.keymap.set("n", "<leader>lg", ":lua require('snacks').lazygit() <CR>", { desc = "Lazy git" })
