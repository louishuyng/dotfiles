vim.keymap.set("n", "<leader>g;",
  ":lua require('config.libs.git_worktree').pull()<CR>")
vim.keymap.set("n", "<leader>gp",
  ":lua require('config.libs.git_worktree').push()<CR>")
vim.keymap.set("n", "<leader>gpf",
  ":lua require('config.libs.git_worktree').push_force()<CR>")
