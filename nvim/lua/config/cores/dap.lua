vim.fn.sign_define('DapBreakpoint',
                   {text = '🟥', texthl = '', linehl = '', numhl = ''})
vim.fn.sign_define('DapStopped', {
  text = '▶️',
  texthl = '',
  linehl = 'DapStopped',
  numhl = ''
})

local dap, dapui, virtual_text = require("dap"), require("dapui"),
                                 require("nvim-dap-virtual-text")

dapui.setup()
virtual_text.setup()

dap.listeners.after.event_initialized["dapui_config"] =
    function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] =
    function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- Golang
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go
dap.adapters.go = {
  type = 'executable',
  command = 'node',
  args = {os.getenv('HOME') .. '/development/vscode-go/dist/debugAdapter.js'}
}
dap.configurations.go = {
  {
    type = 'go',
    name = 'Debug',
    request = 'launch',
    program = '${workspaceFolder}',
    dlvToolPath = os.getenv('HOME') .. '/development/golib/bin/dlv'
  }
}
