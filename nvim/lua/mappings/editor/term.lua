vim.keymap.set("n", "<leader>nn",
               ":VimuxPromptCommand('nnn')<CR><CR>:VimuxZoomRunner<CR>")

vim.keymap.set("n", "<leader>k9",
               ":VimuxPromptCommand('k9s')<CR><CR>:VimuxZoomRunner<CR>")

vim.keymap.set("n", "<leader>ld",
               ":VimuxPromptCommand('lazydocker')<CR><CR>:VimuxZoomRunner<CR>")

vim.keymap.set("n", "<leader>lg",
               ":VimuxPromptCommand('lazygit')<CR><CR>:VimuxZoomRunner<CR>")