-- Check if environment variable is NVIM_BLACK=true then Normal guibg=#000000
-- else Normal guibg=#292B2E
local black = os.getenv("NVIM_BLACK")

if black == "true" then
  vim.cmd([[
    hi Normal guibg=#000000
    hi NormalNC guibg=#000000
    hi SignColumn guibg=#000000
    hi VertSplit guifg=gray guibg=NONE
  ]])
else
  vim.cmd([[
    colorscheme fleet

    hi Normal guibg=#292B2E
    hi NormalNC guibg=#292B2E
    hi SignColumn guibg=#292B2E
    hi VertSplit guifg=gray guibg=NONE
    hi CursorLine guibg=#212026

    hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
    hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE

    hi NvimTreeNormal guibg=#1C1C1C
    hi NvimTreeNormalNC guibg=#1C1C1C
  ]])
end
