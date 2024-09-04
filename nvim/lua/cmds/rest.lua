vim.cmd("autocmd BufEnter *.http nnoremap <CR> :hor Rest run<CR>")
vim.cmd("autocmd BufEnter *.http nnoremap <space>rl :hor Rest run last<CR>")
