vim.keymap.set('n', ',ni', ":lua require('functions.network').show_local_ip()<CR>", { desc = 'Show local ip' })
vim.keymap.set('n', ',nI', ":lua require('functions.network').show_public_ip()<CR>", { desc = 'Show public ip' })
