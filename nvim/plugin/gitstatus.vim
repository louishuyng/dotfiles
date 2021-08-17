function! ToggleGStatus()
  if buflisted(bufname('.git/index'))
    bd .git/index
  else
    Git
    17wincmd_
  endif
endfunction
command! ToggleGStatus :call ToggleGStatus()
nnoremap <silent> ,gs :ToggleGStatus<cr>
