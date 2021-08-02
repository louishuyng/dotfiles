  """""""Git Gutter Config"""""
" Jump between hunks
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
" Hunk-add and hunk-revert for chunk staging
nmap ga <Plug>(GitGutterStageHunk)
nmap gu <Plug>(GitGutterUndoHunk)

noremap <Leader>ga :Gwrite!<CR>
noremap <Leader>gc :Gcommit<CR>   
noremap <space>gp :Gpush
noremap <space>gf :Gpull
noremap <Leader>gs :Gstatus<CR>:17wincmd_<CR>
noremap <space>gs :LazyGit<CR>
noremap <Leader>gb :Git blame<CR>
noremap gb :SingleBlameLine<CR>
noremap <Leader>gd :Gvdiff!<CR>
nnoremap <space>dh :diffget //2<CR>
nnoremap <space>dl :diffget //3<CR>
nnoremap <Leader>o :.Gbrowse<CR>

let g:gitgutter_diff_args = ' '
let g:gitgutter_sign_modified = "▌"
let g:gitgutter_sign_added = "▌" 
let g:gitgutter_sign_removed = '━'
let g:gitgutter_sign_removed_first_line = '━'
let g:gitgutter_sign_modified_removed = '━' 
