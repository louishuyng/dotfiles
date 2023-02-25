vim.cmd([[
  imap <silent><script><expr> <C-n> copilot#Accept("\<CR>")
  let g:copilot_no_tab_map = v:true
]])
