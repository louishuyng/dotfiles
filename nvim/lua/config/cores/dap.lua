local dap = require('dap')
local dapui = require('dapui')

-- Mason DAP integration
require('mason-nvim-dap').setup({
  automatic_installation = true,
  handlers = {},
  ensure_installed = {},
})

-- DAP virtual text
require('nvim-dap-virtual-text').setup({})

-- DAP Go
require('dap-go').setup({})

-- DAP UI
dapui.setup({})
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close({})
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close({})
end

-- DAP signs
local icons = require('config.libs.icons').debug

local signs = {
  DapBreakpoint = { text = icons.Breakpoint, texthl = 'DapBreakpoint', linehl = '', numhl = '' },
  DapBreakpointCondition = {
    text = icons.BreakpointCondition,
    texthl = 'DapBreakpointCondition',
    linehl = '',
    numhl = '',
  },
  DapLogPoint = { text = icons.DebugLogPoint, texthl = 'DapLogPoint', linehl = '', numhl = '' },
  DapStopped = { text = icons.Stopped, texthl = 'DapStopped', linehl = 'Visual', numhl = '' },
  DapBreakpointRejected = {
    text = icons.BreakpointRejected,
    texthl = 'DapBreakpointRejected',
    linehl = '',
    numhl = '',
  },
}
for sign_name, sign_config in pairs(signs) do
  vim.fn.sign_define(sign_name, sign_config)
end

-- VsCode launch.json support
local vscode = require('dap.ext.vscode')
local json = require('plenary.json')
vscode.json_decode = function(str)
  return vim.json.decode(json.json_strip_comments(str))
end

-- JavaScript/TypeScript debug adapter
local mason_pkg_path = vim.fn.stdpath('data') .. '/mason/packages'

if not dap.adapters['pwa-node'] then
  dap.adapters['pwa-node'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
      command = 'node',
      args = {
        mason_pkg_path .. '/js-debug-adapter/js-debug/src/dapDebugServer.js',
        '${port}',
      },
    },
  }
end

if not dap.adapters['node'] then
  dap.adapters['node'] = function(cb, config)
    if config.type == 'node' then
      config.type = 'pwa-node'
    end
    local nativeAdapter = dap.adapters['pwa-node']
    if type(nativeAdapter) == 'function' then
      nativeAdapter(cb, config)
    else
      cb(nativeAdapter)
    end
  end
end

local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

vscode.type_to_filetypes['node'] = js_filetypes
vscode.type_to_filetypes['pwa-node'] = js_filetypes

for _, language in ipairs(js_filetypes) do
  if not dap.configurations[language] then
    dap.configurations[language] = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        cwd = '${workspaceFolder}',
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
      },
    }
  end
end
