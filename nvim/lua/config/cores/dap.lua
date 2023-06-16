local DEBUGGER_PATH = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug"

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

require("dap-vscode-js").setup {
  node_path = "node",
  debugger_path = DEBUGGER_PATH,
  -- debugger_cmd = { "js-debug-adapter" },
  adapters = {
    "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost"
  } -- which adapters to register in nvim-dap
}

for _, language in ipairs {"typescript", "javascript"} do
  require("dap").configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}"
    }, {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}"
    }, {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {"./node_modules/jest/bin/jest.js", "--runInBand"},
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen"
    }
  }
end
