  """""""Git Gutter Config"""""
" Jump between hunks
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
" Hunk-add and hunk-revert for chunk staging
nmap ga <Plug>(GitGutterStageHunk)
nmap gu <Plug>(GitGutterUndoHunk)

noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <space>gp :Gpush
noremap <space>gf :Gpull
noremap <Leader>gs :Gstatus<CR>
noremap <space>gs :LazyGit<CR>
noremap <Leader>gb :Gblame<CR>
noremap gb :SingleBlameLine<CR>
noremap <Leader>gd :Gvdiff<CR>
nnoremap <Leader>o :.Gbrowse<CR>

set statusline+=%{get(b:,'gitsigns_status','')}
