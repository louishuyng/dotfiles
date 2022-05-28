vim.cmd("autocmd BufEnter *.rb nnoremap <leader>mu :Rails db:migrate<CR>")
vim.cmd("autocmd BufEnter *.rb nnoremap <leader>md :Rails db:rollback<CR>")
