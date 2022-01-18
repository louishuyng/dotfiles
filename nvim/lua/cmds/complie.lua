vim.cmd("autocmd BufEnter *.go nnoremap <leader>cp :call VimuxRunCommand('clear; go build ' . bufname('%'))<CR>")
