local neotest = require('neotest')

vim.keymap.set('n', '<space>tf', function()
  neotest.run.run(vim.fn.expand('%'))
end, { desc = 'Test File' })

vim.keymap.set('n', '<space>ts', function()
  neotest.run.run()
end, { desc = 'Test Nearest' })

vim.keymap.set('n', '<space>tl', function()
  neotest.run.run_last()
end, { desc = 'Test Last' })

vim.keymap.set('n', '<space>tc', function()
  neotest.run.run({ strategy = 'dap' })
end, { desc = 'Debug Nearest Test' })

vim.keymap.set('n', '<space>to', function()
  neotest.output.open({ enter = true, auto_close = true })
end, { desc = 'Test Output' })

vim.keymap.set('n', '<space>tp', function()
  neotest.output_panel.open({ enter = true, auto_close = true })
end, { desc = 'Test Output' })

vim.keymap.set('n', '<space>tt', function()
  neotest.summary.toggle()
end, { desc = 'Test Output Panel' })

vim.keymap.set('n', ']t', function()
  neotest.jump.next({ status = 'failed' })
end, { desc = 'Jump to next failed test' })

-- Jump to previous failed test
vim.keymap.set('n', '[t', function()
  neotest.jump.prev({ status = 'failed' })
end, { desc = 'Jump to previous failed test' })
