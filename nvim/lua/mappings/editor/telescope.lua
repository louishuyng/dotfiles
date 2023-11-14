local tmux_session = require('config.cores.telescope.custom.tmux_session')

local opt = {silent = true, noremap = true}

-- Main finding
vim.keymap.set("n", "<c-p>", ":Telescope find_files hidden=true<cr>", opt)
vim.keymap.set("n", "<leader><leader>", ":Telescope buffers<CR>", opt)
vim.keymap.set("n", "<leader>/", ":Telescope live_grep<CR>", opt)
vim.keymap.set("n", "<leader>fm", ":Telescope marks<CR>", opt)
vim.keymap.set("n", "<leader>fj", ":Telescope jumplist<CR>", opt)

-- TODO list
vim.keymap.set("n", "<leader>td", ":TodoTelescope<CR>", opt)

-- prefix with <leader>f
vim.keymap.set("n", "<leader>f/", ":Telescope current_buffer_fuzzy_find<CR>",
               opt)
vim.keymap.set("n", "<leader>fn", ":Telescope notify <CR>", opt)
vim.keymap.set("n", "<leader>fc", ":Telescope flutter commands<CR>", opt)
vim.keymap.set("n", "<leader>fr",
               ":Telescope oldfiles previewer=false cwd_only=true<CR>", opt)

-- searching vim built-in
vim.keymap.set("n", "g?", ":Telescope help_tags<CR>", opt)
vim.keymap.set("n", "<leader><BS>", ":Telescope keymaps<CR>", opt)
vim.keymap.set("n", "<leader>\"", ":Telescope registers<CR>", opt)

-- tmux
vim.keymap.set("n", "<leader>\\", tmux_session)

-- vim config
vim.keymap.set("n", "<leader>vc",
               ":Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>",
               opt)

-- File Browser with the path of the current path
vim.keymap.set("n", ",e", function()
  local telescope = require("telescope")

  local function telescope_buffer_dir() return vim.fn.expand("%:p:h") end

  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = true
  })
end, opt)

-- Resume Previous Telescope
vim.keymap.set("n", ";;", function()
  local builtin = require("telescope.builtin")
  builtin.resume()
end, opt)

-- List diagnostics for all open buffers or a specific buffer
vim.keymap.set("n", "<leader>fd", function()
  local builtin = require("telescope.builtin")
  builtin.diagnostics()
end)

-- Lists Function names, variables, from Treesitter
vim.keymap.set("n", ";s", function()
  local builtin = require("telescope.builtin")
  builtin.treesitter()
end)
