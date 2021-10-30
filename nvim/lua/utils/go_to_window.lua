return function (id)
  vim.fn.win_gotoid("a:"..id)
  vim.api.nvim_command('MaximizerToggle')
end
