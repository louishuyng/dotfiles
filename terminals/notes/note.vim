" Prose settings for notes opened from the tmux popup picker. Sourced
" explicitly via `nvim -c source`, so it never touches normal editing.

function! s:NoteProse() abort
  setlocal spell spelllang=en_us
  setlocal wrap linebreak breakindent
  setlocal conceallevel=2 concealcursor=
  setlocal textwidth=0 colorcolumn=

  " Wrapped prose should navigate the way it looks, not the way it's stored.
  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  nnoremap <buffer> gj j
  nnoremap <buffer> gk k
  xnoremap <buffer> j gj
  xnoremap <buffer> k gk
endfunction

augroup note_popup_prose
  autocmd!
  autocmd FileType markdown call s:NoteProse()
augroup END

" -c commands run after the first file loads, so its FileType already fired.
if &filetype ==# 'markdown'
  call s:NoteProse()
endif
