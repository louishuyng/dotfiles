"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

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

"" Clean search (highlight)
nnoremap <silent> <leader><space> :noh<cr>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

noremap  <silent> <C-s>          :w<CR>
vnoremap <silent> <C-s>         <C-C>:w<CR>
inoremap <silent> <C-s>         <C-O>:w<CR>
inoremap <silent> <C-d> <esc>:q!<cr>               " save and exit
vnoremap <silent> <C-d> <esc>:q!<cr>
nnoremap <silent> <c-d> :q!<cr>

"Apply Macro
vnoremap <leader>m :normal @

"Clear HightLigh Text
nnoremap <esc> :noh<return><esc>

"Auto close Tag
inoremap ><Tab> ><Esc>?<[a-z]<CR>lyiwo</<C-r>"><Esc>O

imap jj <esc>
imap jj <C-\><C-n>

" Use CTRL-S for saving, also in Insert mode
noremap <Cmd-S> :update<CR>
vnoremap <Cmd-S> <C-C>:update<CR>
inoremap <Cmd-S> <C-O>:update<CR>
