noremap <leader>q :bp<CR>
noremap <leader>w :bn<CR>

nnoremap <silent> <leader>b :Buffers<CR>

"" Close buffer
nnoremap <leader>bda :w <bar> %bd <bar> e# <bar> bd# <CR>
noremap <leader>c :bd<CR>

"" Tabs
nnoremap <silent> <S-t> :tabnew<CR>
nnoremap <silent> <leader>W :tabnext<CR>
nnoremap <silent> <leader>Q :tabprevious<CR>
nnoremap <silent> 1<Tab> 1gt
nnoremap <silent> 2<Tab> 2gt
nnoremap <silent> 3<Tab> 3gt
