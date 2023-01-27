vim.keymap.set("n", ",gb", ":Git blame<CR>")
vim.keymap.set("n", "<leader>gd", ":Gvdiff ")

vim.keymap.set("n", "<leader>fc", "::DiffviewFileHistory %<CR>")

vim.keymap.set("n", ",gs", ":Git<CR>:20wincmd_<CR>", {silent = true})

vim.keymap.set("n", "<leader>1",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_oivan <CR><CR>")
vim.keymap.set("n", "<leader>2",
               ":silent !ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/id_rsa_open_source <CR><CR>")

require 'mappings.source_control.conflict'
require 'mappings.source_control.telescope_git'
require 'mappings.source_control.worktree'