vim.cmd("autocmd BufEnter *.go nnoremap <leader>r :call VimuxRunCommand('clear; go run ' . bufname('%'))<CR>")
