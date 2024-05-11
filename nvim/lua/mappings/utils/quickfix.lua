local opt = { silent = true }

-- When in quick fix list, then mapping <C-j> and <C-k> to navigate between
-- quick fix list items.
vim.cmd([[
  augroup quickfix
    au!
    au FileType qf nnoremap <buffer> <C-j> :cn<CR>
    au FileType qf nnoremap <buffer> <C-k> :cp<CR>
  augroup END
]])


vim.keymap.set("n", "<leader>qo", ":copen<CR>", opt)
vim.keymap.set("n", "<leader>qd", "<cmd>call setqflist([])<CR>:cclose<CR>", opt)
