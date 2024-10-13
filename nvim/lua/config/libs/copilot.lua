vim.g.copilot_no_tab_map = true

vim.cmd([[
  imap <silent><script><expr> <Bslash><Bslash> copilot#Accept("\<CR>")
]])
