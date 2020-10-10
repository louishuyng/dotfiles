let g:coc_global_extensions = [
\ 'coc-css',
\ 'coc-json',
\ 'coc-snippets',
\ 'coc-pairs',
\ 'coc-tsserver',
\ 'coc-python',
\ 'coc-git',
\ 'coc-go',
\ 'coc-eslint',
\ 'coc-tslint',
\ 'coc-pairs',
\ 'coc-vimlsp',
\ 'coc-emmet',
\ 'coc-prettier',
\ 'coc-ultisnips'
\ ]
autocmd CursorHold * silent call CocActionAsync('highlight')
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

" Restart Coc
nmap <leader>cr :CocRestart<CR>
" GoTo Code Navigation
nmap <silent> gf <Plug>(coc-definition)
nmap <silent> gff ,v<Plug>(coc-definition)
nmap <silent> gfF ,h<Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gh <Plug>(coc-doHover)

"Remap keys for applying code action and fix current line
nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)

" Remap for rename current word
nmap <leader>rr <Plug>(coc-rename)
nnoremap <leader>rw :CocSearch <C-R>=expand("<cword>")<CR><CR>

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Delay load coc config again, which fix the bug with coc completion does not work at first time start
autocmd VimEnter * call timer_start(200, { tid -> execute('source ~/.config/nvim/config/coc.vim')})
