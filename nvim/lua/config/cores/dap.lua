vim.fn.sign_define('DapBreakpoint',
  { text = '🟥', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', {
  text = '▶️',
  texthl = '',
  linehl = 'DapStopped',
  numhl = ''
})

local dap, dapui, virtual_text = require("dap"), require("dapui"),
    require("nvim-dap-virtual-text")
-- Init
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
  args = { os.getenv('HOME') .. '/development/vscode-go/dist/debugAdapter.js' }
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

-- JS
local js_based_languages = {
  "typescript", "javascript", "typescriptreact", "javascriptreact", "vue"
}
for _, language in ipairs(js_based_languages) do
  dap.configurations[language] = {
    -- Debug single nodejs files
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true
    },
    -- Debug nodejs processes (make sure to add --inspect when you run the process)
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = vim.fn.getcwd(),
      sourceMaps = true
    }, -- Debug web applications (client side)
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Launch & Debug Chrome",
      url = function()
        local co = coroutine.running()
        return coroutine.create(function()
          vim.ui.input({
            prompt = "Enter URL: ",
            default = "http://localhost:3800"
          }, function(url)
            if url == nil or url == "" then
              return
            else
              coroutine.resume(co, url)
            end
          end)
        end)
      end,
      webRoot = vim.fn.getcwd(),
      protocol = "inspector",
      sourceMaps = true,
      userDataDir = false
    }, -- Divider for the launch.json derived configs
    {
      name = "----- ↓ launch.json configs ↓ -----",
      type = "",
      request = "launch"
    }
  }
end
