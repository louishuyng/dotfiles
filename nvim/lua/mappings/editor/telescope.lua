local opt = {silent = true}

vim.keymap.set("n", "<leader><leader>",
               ":Telescope find_files hidden=true layout_config={'width':0.7}<cr>",
               opt)
vim.keymap.set("n", "<leader>/",
               ":Telescope live_grep layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "<leader>?",
               ":Telescope help_tags layout_config={'width':0.7}<CR>", opt)

vim.keymap.set("n", "<leader>fr",
               ":Telescope oldfiles previewer=false cwd_only=true<CR>", opt)

vim.keymap.set("n", "<leader>bb", ":Telescope buffers<CR>", opt)
vim.keymap.set("n", "<leader>fc", ":Telescope flutter commands<CR>", opt)
vim.keymap.set("n", "<leader><BS>", ":Telescope keymaps<CR>", opt)

vim.keymap.set("n", "<leader>vc",
               ":Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>",
               opt)
vim.keymap.set("n", "<leader>td",
               ":TodoTelescope layout_config={'width':0.7}<CR>")
