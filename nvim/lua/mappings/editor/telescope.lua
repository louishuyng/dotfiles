local opt = {silent = true}

vim.keymap.set("n", "<C-p>",
               ":Telescope find_files hidden=true layout_config={'width':0.7}<cr>",
               opt)
vim.keymap.set("n", "tf",
               ":Telescope live_grep layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "tt",
               ":Telescope treesitter layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "th",
               ":Telescope help_tags layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "to",
               ":Telescope oldfiles previewer=false cwd_only=true<CR>", opt)
vim.keymap.set("n", "tp", ":Telescope project<CR>", opt)

vim.keymap.set("n", "tb", ":Telescope buffers<CR>", opt)
vim.keymap.set("n", "tc", ":Telescope flutter commands<CR>", opt)

vim.keymap.set("n", "<leader>vrc",
               ":Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>",
               opt)
vim.keymap.set("n", "<leader>td",
               ":TodoTelescope layout_config={'width':0.7}<CR>")
