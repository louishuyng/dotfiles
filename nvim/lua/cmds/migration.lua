vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.rb",
  callback = function()
    vim.keymap.set('n', '<leader>mu', ':Rails db:migrate<CR>', { buffer = true })
    vim.keymap.set('n', '<leader>md', ':Rails db:rollback<CR>', { buffer = true })
  end,
})
