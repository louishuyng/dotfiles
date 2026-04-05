local map = vim.keymap.set

-- DAP
map('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'Breakpoint Condition' })
map('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
map('n', '<leader>dc', function() require('dap').continue() end, { desc = 'Run/Continue' })
map('n', '<leader>dC', function() require('dap').run_to_cursor() end, { desc = 'Run to Cursor' })
map('n', '<leader>dg', function() require('dap').goto_() end, { desc = 'Go to Line (No Execute)' })
map('n', '<leader>di', function() require('dap').step_into() end, { desc = 'Step Into' })
map('n', '<leader>dj', function() require('dap').down() end, { desc = 'Down' })
map('n', '<leader>dk', function() require('dap').up() end, { desc = 'Up' })
map('n', '<leader>dl', function() require('dap').run_last() end, { desc = 'Run Last' })
map('n', '<leader>do', function() require('dap').step_out() end, { desc = 'Step Out' })
map('n', '<leader>dO', function() require('dap').step_over() end, { desc = 'Step Over' })
map('n', '<leader>dP', function() require('dap').pause() end, { desc = 'Pause' })
map('n', '<leader>dr', function() require('dap').repl.toggle() end, { desc = 'Toggle REPL' })
map('n', '<leader>ds', function() require('dap').session() end, { desc = 'Session' })
map('n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Terminate' })
map('n', '<leader>dw', function() require('dap.ui.widgets').hover() end, { desc = 'Widgets' })

-- DAP UI
map('n', '<leader>du', function() require('dapui').toggle({}) end, { desc = 'Dap UI' })
map({ 'n', 'v' }, '<leader>de', function() require('dapui').eval() end, { desc = 'Eval' })
