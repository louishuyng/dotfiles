vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.http",
  callback = function()
    vim.keymap.set('n', '<CR>', ':hor Rest run<CR>', { buffer = true })
    vim.keymap.set('n', '<space>rl', ':hor Rest run last<CR>', { buffer = true })
  end,
})
