local opt = {silent = true}

vim.keymap.set("n", "<leader><leader>", ":Telescope find_files hidden=true<cr>",
               opt)
vim.keymap.set("n", "<leader>ns",
               ":lua vim.cmd('NvimTreeFocus');vim.cmd('Telescope find_files hidden=true')<CR>",
               opt)

vim.keymap.set("n", "<leader>/", ":Telescope live_grep<CR>", opt)
vim.keymap.set("n", "<leader>fb", ":Telescope current_buffer_fuzzy_find<CR>",
               opt)
vim.keymap.set("n", "<leader>?", ":Telescope help_tags<CR>", opt)

vim.keymap.set("n", "<leader>fr",
               ":Telescope oldfiles previewer=false cwd_only=true<CR>", opt)

vim.keymap.set("n", "<leader>bb", ":Telescope buffers<CR>", opt)
vim.keymap.set("n", "<leader>fc", ":Telescope flutter commands<CR>", opt)
vim.keymap.set("n", "<leader><BS>", ":Telescope keymaps<CR>", opt)

vim.keymap.set("n", "<leader>vc",
               ":Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>",
               opt)
vim.keymap.set("n", "<leader>td", ":TodoTelescope<CR>", opt)

vim.keymap.set("n", "<leader>fn", ":Telescope notify <CR>", opt)
vim.keymap.set("n", "<leader>fe", ":Telescope env<CR>", opt)
