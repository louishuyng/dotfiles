local cmd = vim.cmd

cmd("hi Search cterm=NONE ctermfg=NONE ctermbg=240 guifg=NONE guibg=#585858")
cmd("hi DiffAdd cterm=NONE ctermfg=NONE ctermbg=236 guifg=NONE guibg=#303030")
cmd("hi DiffChange cterm=NONE ctermfg=NONE ctermbg=238 guifg=NONE guibg=#444444")
cmd("hi DiffDelete cterm=reverse ctermfg=0 ctermbg=88 guibg=#000000 guifg=#3c1f1e")
cmd("hi DiffText cterm=NONE ctermfg=NONE ctermbg=23 guifg=NONE guibg=#005f5f")
cmd("hi Normal guibg=NONE")
cmd("hi EndOfBuffer guibg=NONE")
cmd("hi FloatermBorder guifg=#55E579")
cmd("hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE")
cmd("hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE")
cmd("hi CursorLine guibg=NONE guifg=NONE")
