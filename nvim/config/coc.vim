let g:global_extensions = [
  \'coc-fzf-preview',
  \'coc-explorer',
  \'coc-ultisnips',
  \'coc-highlight',
  \'coc-tabnine',
  \'coc-phpls',
  \'coc-json',
  \'coc-tsserver',
  \'coc-css',
  \'coc-html',
  \'coc-solargraph',
  \'coc-yaml',
  \'coc-python',
  \'coc-svg',
  \'coc-flow',
  \'coc-go'
  \]

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

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

nmap <space>e :CocCommand explorer<CR>

" Explorer
let g:coc_explorer_global_presets = {
\   'floating': {
\      'position': 'floating',
\   },
\   'floatingLeftside': {
\      'position': 'floating',
\      'floating-position': 'left-center',
\      'floating-width': 30,
\   },
\   'floatingRightside': {
\      'position': 'floating',
\      'floating-position': 'right-center',
\      'floating-width': 30,
\   },
\   'simplify': {
\     'file.child.template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   }
\ }

" Delay load coc config again, which fix the bug with coc completion does not work at first time start
autocmd VimEnter * call timer_start(200, { tid -> execute('source ~/.config/nvim/config/coc.vim')})
