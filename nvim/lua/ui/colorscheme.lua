vim.cmd([[
  let g:edge_transparent_background = 1
  colorscheme edge

  hi Normal guibg=#0F0F0F
  hi NormalNC guibg=#0F0F0F
  hi VertSplit guifg=#2B2B2B guibg=NONE

  hi TelescopePreviewBorder guibg=#21252E guifg=#21252E
  hi TelescopePreviewNormal guibg=#21252E
  hi TelescopePreviewTitle guibg=#21252E guifg=#21252E
  hi TelescopePromptBorder guibg=#2E323B guifg=#2E323B
  hi TelescopePromptCounter guifg=#c0afff gui=bold
  hi TelescopePromptNormal guibg=#2E323B
  hi TelescopePromptPrefix guibg=#2E323B
  hi TelescopePromptTitle guifg=#2E323B guibg=#2E323B
  hi TelescopeResultsBorder guibg=#222222 guifg=#222222
  hi TelescopeResultsNormal guibg=#222222
  hi TelescopeResultsTitle guibg=#222222 guifg=#222222
  hi TelescopeSelection guibg=#2E323B

  hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
  hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE

  hi AlphaHeader guifg=#89b482
  hi AlphaButton guifg=#89b482
  hi AlphaFooter guifg=#89b482

  hi Search cterm=NONE ctermfg=NONE ctermbg=240 guifg=NONE guibg=#585858

  hi DiffAdd cterm=NONE ctermfg=NONE ctermbg=236 guifg=NONE guibg=#303030
  hi DiffChange cterm=NONE ctermfg=NONE ctermbg=238 guifg=NONE guibg=#2E323B
  hi DiffDelete cterm=reverse ctermfg=0 ctermbg=88 guibg=#0F0F0F guifg=#be5046
  hi DiffText cterm=NONE ctermfg=NONE ctermbg=23 guifg=NONE guibg=#005f5f

  hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#323232 gui=NONE
  hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE
  hi CursorLine guibg=#323232 guifg=NONE
]])
