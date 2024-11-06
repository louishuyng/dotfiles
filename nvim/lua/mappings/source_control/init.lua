vim.keymap.set("n", ",gb", ":Gitsigns blame<CR>", { silent = true })

vim.keymap.set("n", "<leader>tb", ":Gitsigns toggle_current_line_blame<CR>",
  { silent = true })

vim.keymap.set("n", "<leader>gd", ":Gvdiff ")

vim.keymap.set("n", "<leader>dvf", ":DiffviewFileHistory %<CR>")
vim.keymap.set("n", "<leader>dva", ":DiffviewFileHistory <CR>")
vim.keymap.set("n", "<leader>dvo", ":DiffviewOpen<CR>")
vim.keymap.set("n", "<leader>dvc", ":DiffviewClose<CR>")

vim.keymap.set("n", ",gs", ":Git<CR>:15wincmd_<CR>", { silent = true })

vim.keymap.set("n", "<leader>1",
  ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/open_source <CR><CR>")

require 'mappings.source_control.conflict'
require 'mappings.source_control.telescope_git'
require 'mappings.source_control.worktree'
