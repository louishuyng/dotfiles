vim.cmd("autocmd BufEnter *.go nnoremap <space>r :call VimuxRunCommand('clear; go run ' . bufname('%'))<CR>")
