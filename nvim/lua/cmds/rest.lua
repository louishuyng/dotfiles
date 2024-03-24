vim.cmd("autocmd BufEnter *.http nnoremap <CR> :Rest run<CR>")
vim.cmd("autocmd BufEnter *.http nnoremap <space>rl :Rest run last<CR>")
