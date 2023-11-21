require "ui/icons"
require "ui/lsp"

vim.cmd([[
  let g:edge_transparent_background = 1
  let g:edge_better_performance = 1
  let g:edge_diagnostic_text_highlight = 1

  colorscheme edge

  hi VertSplit guifg=#778092
  hi AlphaHeader guifg=#98c379

  hi FlashMatch guibg=#1e1e1e guifg=#98c379 gui=bold
  hi FlashLabel guibg=#1e1e1e guifg=#98c379 gui=bold
]])
