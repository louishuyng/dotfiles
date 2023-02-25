vim.keymap.set("i", "<C-n>", "<Plug>(copilot-next)")
vim.keymap.set("i", "<C-p>", "<Plug>(copilot-previous)")

vim.cmd([[
  imap <silent><script><expr> <Bslash><Bslash> copilot#Accept("\<CR>")
  let g:copilot_no_tab_map = v:true
]])
