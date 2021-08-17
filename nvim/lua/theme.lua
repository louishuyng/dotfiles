local cmd = vim.cmd

cmd('colorscheme one-nvim')

-- Highlights
cmd[[au VimEnter * highlight Normal guibg=#000000]]
cmd[[au VimEnter * highlight EndOfBuffer guibg=#000000]]
cmd[[au VimEnter * highlight SignColumn guibg=NONE ctermbg=NONE]]
cmd[[au VimEnter * highlight default LspSagaFinderSelection guifg=#0000 guibg=NONE gui=NONE]]