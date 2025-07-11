vim.keymap.set('n', '<space>tf', function()
  require('neotest').run.run(vim.fn.expand('%'))
end, { desc = 'Test File' })

vim.keymap.set('n', '<space>ts', function()
  require('neotest').run.run()
end, { desc = 'Test Nearest' })

vim.keymap.set('n', '<space>tl', function()
  require('neotest').run.run_last()
end, { desc = 'Test Last' })

vim.keymap.set('n', '<space>tc', function()
  require('neotest').run.run({ strategy = 'dap' })
end, { desc = 'Debug Nearest Test' })

vim.keymap.set('n', '<space>to', function()
  require('neotest').output.open({ enter = true, auto_close = true })
end, { desc = 'Test Output' })

vim.keymap.set('n', '<space>tt', function()
  require('neotest').summary.toggle()
end, { desc = 'Test Output Panel' })
