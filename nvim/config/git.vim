noremap <Leader>ga :Gwrite!<CR>
noremap <Leader>gc :Gcommit<CR>   
noremap <space>gp :Gpush
noremap <space>gf :Gpull
nnoremap <silent> <Leader>gs :Git<CR>:20wincmd_<CR>
noremap <space>gs :LazyGit<CR>
noremap <Leader>gb :Git blame<CR>
noremap gb :SingleBlameLine<CR>
noremap <Leader>gd :Gvdiff!<CR>
nnoremap <space>dh :diffget //2<CR>
nnoremap <space>dl :diffget //3<CR>
nnoremap <Leader>o :.Gbrowse<CR>
