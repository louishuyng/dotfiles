local telescope = require("telescope")
local dropdown_theme = require("config.cores.telescope.theme").dropdown_theme

local opt = { silent = true, noremap = true }

-- Main finding
vim.keymap.set("n", "<c-p>", function()
  require('telescope.builtin').find_files(dropdown_theme("Files"))
end, opt)

vim.keymap.set("n", "<leader>fb", function()
  return require('telescope.builtin').buffers(dropdown_theme("Buffers"))
end, opt)

vim.keymap.set("n", "<leader>/",
  function()
    return require('telescope').extensions.live_grep_args.live_grep_args(dropdown_theme("LiveGrep", true))
  end,
  opt)

vim.keymap.set("n", "<leader>fm", function()
  return require('telescope.builtin').marks(dropdown_theme("Marks"))
end, opt)

vim.keymap.set("n", "<leader>fj", function()
  return require('telescope.builtin').jumplist(dropdown_theme("Jumplist", true))
end, opt)

-- -- LSP Finding
vim.keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references(dropdown_theme("References", true))
end, opt)

-- TODO list
vim.keymap.set("n", "<leader>td", ":TodoTelescope<CR>", opt)

-- prefix with <leader>f
vim.keymap.set("n", "<leader>f/", function()
  return require('telescope.builtin').current_buffer_fuzzy_find(dropdown_theme("CurrentBuffer"))
end, opt)

vim.keymap.set("n", "<leader>fr",
  function()
    return require('telescope.builtin').oldfiles(dropdown_theme("OldFiles"))
  end,
  opt)

-- searching vim built-in
vim.keymap.set("n", "g?", function()
  return require('telescope.builtin').help_tags(dropdown_theme("HelpTags"))
end, opt)

vim.keymap.set("n", "<leader><BS>",
  function()
    require('telescope.builtin').keymaps(dropdown_theme("Keymaps"))
  end, opt)

vim.keymap.set("n", "<leader>\"", function()
  require('telescope.builtin').registers(dropdown_theme("Registers"))
end, opt)

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
    previewer = true,
  })
end, opt)

-- Resume Previous Telescope
vim.keymap.set("n", "<leader>fl", function()
  local builtin = require("telescope.builtin")

  builtin.resume(dropdown_theme("Resume"))
end, opt)

-- List diagnostics for all open buffers or a specific buffer
vim.keymap.set("n", "<leader>fd", function()
  local builtin = require("telescope.builtin").diagnostics(dropdown_theme("Diagnostics"))
end)

-- -- NEST JS
-- vim.keymap.set("n", "<leader>fn", function()
--   require('config.cores.telescope.custom.nest_js')({
--     search = vim.fn.input("Search nest_js: ")
--   })
-- end)

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

-- Select theme
vim.keymap.set("n", "<leader>ct", function()
  require('config.cores.telescope.custom.theme_select')()
end)
