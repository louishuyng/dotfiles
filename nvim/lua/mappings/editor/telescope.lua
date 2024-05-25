local scopes = require("neoscopes")
local telescope = require("telescope")

local opt = { silent = true, noremap = true }

-- Helper functions to fetch the current scope and set `search_dirs`
_G.find_files = function()
  require('telescope.builtin').find_files({
    search_dirs = scopes.get_current_dirs()
  })
end
_G.live_grep = function()
  require('telescope.builtin').live_grep({
    search_dirs = scopes.get_current_dirs()
  })
end
vim.keymap.set("n", "<leader>fs", ":lua find_files()<CR>", opt)
vim.keymap.set("n", "<leader>ls", ":lua live_grep()<CR>", opt)

-- Main finding
vim.keymap.set("n", "<c-p>", ":Telescope find_files hidden=true<cr>", opt)
vim.keymap.set("n", "<leader><leader>", ":Telescope buffers<CR>", opt)
vim.keymap.set("n", "<leader>/",
  ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
  opt)

vim.keymap.set("n", "<leader>fm", ":Telescope marks<CR>", opt)
vim.keymap.set("n", "<leader>fj", ":Telescope jumplist<CR>", opt)

-- TODO list
vim.keymap.set("n", "<leader>td", ":TodoTelescope<CR>", opt)

-- prefix with <leader>f
vim.keymap.set("n", "<leader>f/", ":Telescope current_buffer_fuzzy_find<CR>",
  opt)
vim.keymap.set("n", "<leader>fr", ":Telescope oldfiles previewer=false cwd_only=true<CR>", opt)

-- searching vim built-in
vim.keymap.set("n", "g?", ":Telescope help_tags<CR>", opt)
vim.keymap.set("n", "<leader><BS>", ":Telescope keymaps<CR>", opt)
vim.keymap.set("n", "<leader>\"", ":Telescope registers<CR>", opt)

-- vim config
vim.keymap.set("n", "<leader>vc",
  ":Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>",
  opt)

-- File Browser with the path of the current path
vim.keymap.set("n", ",e", function()
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
vim.keymap.set("n", "<leader>fl", function()
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

-- Refactoring
vim.keymap.set({ "n", "x" }, "<leader>rf", function()
  require('telescope').extensions.refactoring.refactors()
end)

-- NEST JS
vim.keymap.set("n", "<leader>fn", function()
  require('config.cores.telescope.custom.nest_js')({
    search = vim.fn.input("Search nest_js: ")
  })
end)

-- Rest
vim.keymap.set("n", "<leader>ce", function()
  require("telescope").extensions.rest.select_env()
end)

vim.keymap.set("n", "<leader>fa", function()
  require("telescope.builtin").find_files({
    prompt_title = "APIs",
    find_command = { "fd", "--type", "f", "--extension", "http" }
  })
end)

vim.keymap.set("n", "<C-e>",
  ":Telescope harpoon marks previewer=true<CR>", opt)
