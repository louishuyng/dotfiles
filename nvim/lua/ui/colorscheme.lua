local note = os.getenv("NVIM_NOTE")

if vim.g.dark_mode then
  vim.cmd([[
    set background=dark
    colorscheme catppuccin

    set laststatus=3 | set showtabline=1

    hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#16181C gui=NONE
    hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE guifg=#000000 guibg=#55E579 gui=NONE

    hi Cursorline guibg=#252525
    hi ColorColumn guibg=#252525

    hi Normal guibg=#191C19
    hi NormalNC guibg=#191C19
    hi SignColumn guibg=#191C19

    hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
    hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE
  ]])
else
  vim.cmd([[
    set background=light
    colorscheme catppuccin

    set laststatus=3 | set showtabline=1

    hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE guifg=NONE guibg=#f0f0f0 gui=NONE

    hi Cursorline guibg=#D7D7D7
    hi ColorColumn guibg=#D7D7D7

    hi NvimTreeGitStaged guifg=#99cc99 guibg=NONE
    hi NvimTreeGitDirty guifg=#cc6666 guibg=NONE
  ]])
end

if note == "true" then
  vim.g.dark_mode = "true"
  vim.cmd([[
    set background=dark
    colorscheme catppuccin
  ]])
end
