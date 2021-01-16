" Airline
" Enable Airline
let g:airline#extensions#branch#enabled = 1
" Show list of buffers in tabline
let g:airline#extensions#tabline#enabled = 0
" Show just the filename in tabline
let g:airline#extensions#tabline#fnamemod = ':t'
" Use fonts
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
     let g:airline_symbols = {}
endif
" Airline symbols
let g:airline_left_sep = "\uE0C0"
let g:airline_right_sep = "\uE0C2"
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" Airline theme
let g:airline_theme='atomic'
