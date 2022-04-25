local opt = {silent = true}

vim.keymap.set("n", "<c-p>", "<cmd>Telescope find_files hidden=true layout_config={'width':0.7}<cr>", opt)
vim.keymap.set("n", "<leader>f", "<cmd>Telescope live_grep layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "<leader>t", "<cmd>Telescope treesitter layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "<leader>h", "<cmd>Telescope help_tags layout_config={'width':0.7}<CR>", opt)
vim.keymap.set("n", "<leader>o", "<cmd>Telescope oldfiles previewer=false cwd_only=true<CR>", opt)
vim.keymap.set("n", "<leader>p", "<cmd>Telescope project<CR>", opt)
vim.keymap.set("n", "<leader>vrc", "<cmd>Telescope find_files prompt_title=<VimRC> cwd=~/.dotfiles hidden=true<CR>", opt)
vim.keymap.set("n", "<leader>gs", ":Telescope git_stash<CR>", opt)
