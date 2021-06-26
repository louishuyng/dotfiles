  """""""Git Gutter Config"""""
" Jump between hunks
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
" Hunk-add and hunk-revert for chunk staging
nmap ga <Plug>(GitGutterStageHunk)
nmap gu <Plug>(GitGutterUndoHunk)

noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>ge :Gedit<CR>
noremap <Leader>gs :LazyGit<CR>
noremap <Leader>gb :Gblame<CR>
noremap gb :SingleBlameLine<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>
noremap <Leader>gl :Glog<CR>
nnoremap <Leader>o :.Gbrowse<CR>

nnoremap <silent> <Leader>c  :Commits<CR>

set statusline+=%{get(b:,'gitsigns_status','')}
