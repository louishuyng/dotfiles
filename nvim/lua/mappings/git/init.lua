vim.keymap.set("n", "<leader>ga", ":Gwrite!<CR>")

vim.keymap.set("n", ",gb", ":Git blame<CR>")
--
vim.keymap.set("n", "<leader>fc", ":BCommits<CR>")

vim.keymap.set("n", ",gs", ":Git<CR>:20wincmd_<CR>", {silent = true})

vim.keymap.set("n", "<leader>1",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_oivan <CR><CR>")
vim.keymap.set("n", "<leader>2",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_open_source <CR><CR>")

require 'mappings.git.conflict'
require 'mappings.git.telescope_git'
require 'mappings.git.worktree'
