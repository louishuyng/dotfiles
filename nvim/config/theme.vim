hi Normal guibg=#000000
hi EndOfBuffer guibg=#000000

hi LineNr ctermbg=NONE guibg=NONE
hi VertSplit guifg=NONE guibg=#000000 gui=NONE cterm=NONE
hi NvimInternalError guifg=#f9929b
hi SignColumn guifg=#000000 guibg=NONE
hi Visual term=reverse cterm=reverse
hi LineNr         ctermfg=DarkMagenta guifg=#2b506e guibg=#000000 
hi CursorLine     guibg=#222222 gui=none

" Status Line
hi StatusLineMode guifg=#ffffff guibg=#ffffff guisp=#5A7CD8 gui=bold ctermfg=NONE ctermbg=77 cterm=bold
autocmd InsertEnter * hi StatusLineMode guifg=#ffffff guibg=#2F9563 guisp=#2F9563 gui=bold ctermfg=NONE ctermbg=77 cterm=bold
autocmd InsertLeave * hi StatusLineMode guifg=#ffffff guibg=#5A7CD8 guisp=#5A7CD8 gui=bold ctermfg=NONE ctermbg=77 cterm=bold
hi StatusLine guifg=#fdf7cd guibg=#000000 guisp=#000000 gui=bold ctermfg=230 ctermbg=234 cterm=bold
hi StatusLineNC guifg=#ffffff guibg=#171717 guisp=#171717 gui=bold ctermfg=73 ctermbg=234 cterm=bold

" Git Gutter
highlight! GitGutterAdd ctermfg=22 guifg=#006000 ctermbg=NONE guibg=NONE
highlight! GitGutterChange ctermfg=58 guifg=#5F6000 ctermbg=NONE guibg=NONE
highlight! GitGutterDelete ctermfg=52 guifg=#600000 ctermbg=NONE guibg=NONE
highlight! GitGutterChangeDelete ctermfg=52 guifg=#600000 ctermbg=NONE guibg=NONE
