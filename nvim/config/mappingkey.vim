"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"" Copy/Paste/Cut
if has('unnamedplus')
set clipboard=unnamed,unnamedplus
endif

noremap YY "+y<CR>
noremap XX "+x<CR>

if has('macunix')
" pbcopy for OSX copy/paste
vmap <C-x> :!pbcopy<CR>
vmap <C-c> :w !pbcopy<CR><CR>
endif

"Search Visual Selected Text
vnoremap / y/<C-R>"<CR>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

noremap  <silent> <C-s> :w!<CR>
vnoremap <silent> <C-s> <C-C>:w!<CR>
inoremap <silent> <C-s> <C-O>:w!<CR>
inoremap <silent> <C-d> <esc>:q!<cr>
vnoremap <silent> <C-d> <esc>:q!<cr>
nnoremap <silent> <c-d> :q!<cr>

"Apply Macro
vnoremap <Leader>m :normal @

"Auto close Tag
inoremap ><Tab> ><Esc>?<[a-z]<CR>lyiwo</<C-r>"><Esc>O


"Move block
let g:move_map_keys = 0
vmap <S-j> <Plug>MoveBlockDown
vmap <S-k> <Plug>MoveBlockUp
vmap <S-h> <Plug>MoveBlockLeft
vmap <S-l> <Plug>MoveBlockRight
