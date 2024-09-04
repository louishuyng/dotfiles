vim.keymap.set("i", "<C-n>", "<Plug>(copilot-next)")
vim.keymap.set("i", "<C-p>", "<Plug>(copilot-previous)")

vim.cmd([[
  imap <silent><script><expr> <Bslash><Bslash> copilot#Accept("\<CR>")
]])

require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})
