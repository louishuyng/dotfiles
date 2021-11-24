vim.cmd("autocmd BufEnter *.go nnoremap <leader>r :call VimuxRunCommand('clear; go run ' . bufname('%'))<CR>")
vim.cmd("autocmd BufEnter *.js nnoremap <leader>r :call VimuxRunCommand('clear; node ' . bufname('%'))<CR>")
