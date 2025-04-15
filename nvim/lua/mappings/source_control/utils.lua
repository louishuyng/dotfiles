vim.keymap.set('n', '<leader>g;', ":lua require('config.libs.git_utils').pull()<CR>")
vim.keymap.set('n', '<leader>gp', ":lua require('config.libs.git_utils').push()<CR>")
