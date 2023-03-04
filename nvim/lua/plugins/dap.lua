return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      "theHamsta/nvim-dap-virtual-text", "rcarriga/nvim-dap-ui",
      "mxsdev/nvim-dap-vscode-js"
    }
  }, {
    "microsoft/vscode-js-debug",
    lazy = true,
    build = "npm install && npx gulp vsDebugServerBundle && mv dist out"

  }
}
