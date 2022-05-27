vim.keymap.set("n", ",ni",
               ":lua require('functions.network').show_local_ip()<CR>")
vim.keymap.set("n", ",nI",
               ":lua require('functions.network').show_public_ip()<CR>")
