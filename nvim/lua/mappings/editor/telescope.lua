local tmux_session = require('config.cores.telescope.custom.tmux_session')

local opt = {silent = true, noremap = true}

-- Main finding
vim.keymap.set("n", "<c-p>", ":Telescope find_files hidden=true<cr>", opt)
vim.keymap.set("n", "<leader><leader>", ":Telescope buffers<CR>", opt)
vim.keymap.set("n", "<leader>/", ":Telescope live_grep<CR>", opt)
vim.keymap.set("n", "<leader>fm", ":Telescope marks<CR>", opt)
vim.keymap.set("n", "<leader>fj", ":Telescope jumplist<CR>", opt)
vim.keymap.set("n", "<c-m>", function()
  require("telescope.builtin").lsp_document_symbols({
    symbol_width = 50,
    symbols = {"Method"}
  })
end, opt)

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

-- Trouble
vim.keymap.set("n", "<leader>fd", ":TroubleToggle<CR>")
