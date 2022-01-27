local cmd = vim.cmd

cmd[[au VimEnter * highlight FloatermBorder guifg=#55E579]]
cmd[[au VimEnter * highlight Sneak guifg=black guibg=#00C7DF ctermfg=black ctermbg=cyan]]
cmd[[au VimEnter * highlight SneakScope guifg=red guibg=yellow ctermfg=red ctermbg=yellow]]
cmd[[au VimEnter * highlight SignColumn guifg=NONE guibg=NONE]]
cmd[[au VimEnter * highlight MatchParen guifg=#C6C6C6 guibg=NONE]]
cmd[[au VimEnter * highlight GitGutterAdd    guifg=#98c379 guibg=NONE ctermfg=2 ]]
cmd[[au VimEnter * highlight GitGutterChange guifg=#e5c07b guibg=NONE ctermfg=3 ]]
cmd[[au VimEnter * highlight GitGutterDelete guifg=#e88388 guibg=NONE ctermfg=1 ]]
cmd[[au VimEnter * highlight CursorLine guibg=#323232 guifg=NONE ]]
cmd[[au VimEnter * highlight ColorColumn guibg=#323232 guifg=NONE ]]

cmd[[au VimEnter * highlight VertSplit gui=NONE ]]

-- LIST
cmd[[au VimEnter * highlight NonText ctermfg=16 guifg=#48e566 guibg=NONE ]]
