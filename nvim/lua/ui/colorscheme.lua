local note = os.getenv("NVIM_NOTE")

vim.cmd([[
  colorscheme fleet

  hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
  hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE

  hi NvimTreeNormal guibg=#1C1C1C
  hi NvimTreeNormalNC guibg=#1C1C1C
]])

if note == "true" then
  vim.cmd([[
    hi Normal guibg=#0F0F0F
    hi NormalNC guibg=#0F0F0F
    hi SignColumn guibg=#0F0F0F
    hi VertSplit guifg=gray guibg=NONE
    ]])
else
  vim.cmd([[
    hi Normal guibg=#2B2A33
    hi NormalNC guibg=#2B2A33
    hi SignColumn guibg=#2B2A33
    hi VertSplit guifg=gray guibg=NONE
    hi CursorLine guibg=#212026
    ]])
end
