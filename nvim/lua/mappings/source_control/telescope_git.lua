vim.keymap.set("n", "<leader>gb", ":Telescope git_branches<CR>")
vim.keymap.set("n", "<leader>gc", ":Telescope git_commits<CR>")
vim.keymap.set("n", "<leader>gs", ":Telescope git_stash<CR>")
vim.keymap.set("n", "<leader>gws",
               ":lua require('telescope').extensions.git_worktree.git_worktrees()<CR>")
vim.keymap.set("n", "<leader>gwc",
               ":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>")
vim.keymap.set("n", "<leader>gl", ":Git log<CR>")
