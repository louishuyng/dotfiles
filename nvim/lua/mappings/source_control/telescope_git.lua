vim.keymap.set('n', '<leader>gb', ':Telescope git_branches<CR>', { desc = 'Show git branches' })
vim.keymap.set('n', '<leader>gc', ':Telescope git_commits<CR>', { desc = 'Show git commits' })
vim.keymap.set('n', '<leader>gS', ':Telescope git_stash<CR>', { desc = 'Show git stash' })
vim.keymap.set('n', '<leader>gw', ':Telescope git_worktree<CR>', { desc = 'Show git worktree' })
vim.keymap.set(
  'n',
  '<leader>ga',
  ":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
  { desc = 'Add new git worktree' }
)
vim.keymap.set('n', '<leader>gl', ':Git log<CR>', { desc = 'Git log' })
vim.keymap.set('n', '<leader>gs', ':Telescope git_status<CR>', { desc = 'Git status' })
