local note = os.getenv("NVIM_NOTE")

if vim.g.dark_mode then
  vim.cmd([[
    hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
    hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE

    hi Normal guibg=#262626
    hi NormalNC guibg=#262626
    hi SignColumn guibg=#262626

    hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
    hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE

    set background=dark
    let g:edge_better_performance = 1
    colorscheme edge
  ]])
else
  vim.cmd([[
    hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#f0f0f0 gui=NONE

    hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
    hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE

    set background=light
    let g:edge_better_performance = 1
    colorscheme edge
  ]])
end

if note == "true" then
  vim.g.dark_mode = "true"
  vim.cmd([[
    set background=dark
    colorscheme edge
  ]])
end
