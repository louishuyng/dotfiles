vim.g['test#strategy'] = "neovim"
vim.g['test#neovim#term_position'] = "rightbelow 15"
vim.cmd([[
  if has('nvim')
    tmap <C-o> <C-\><C-n>
  endif
]])
