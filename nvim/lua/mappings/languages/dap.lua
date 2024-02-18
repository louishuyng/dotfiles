local opts = {noremap = true, silent = true}

vim.keymap.set('n', '<leader>db', ":DapToggleBreakpoint<CR>", opts)
vim.keymap.set('n', '<leader>dc', ":DapContinue<CR>", opts)
vim.keymap.set('n', '<leader>dl', ":DapStepOver<CR>", opts)
vim.keymap.set('n', '<leader>dj', ":DapStepInto<CR>", opts)
vim.keymap.set('n', '<leader>dk', ":DapStepOut<CR>", opts)
vim.keymap.set('n', '<leader>dt', ":DapTerminate<CR>")
vim.keymap.set('n', '<leader>dr',
               ":lua require('dapui').open({reset = true})<CR>")

local js_based_languages = {
  "typescript", "javascript", "typescriptreact", "javascriptreact", "vue"
}
vim.keymap.set('n', '<leader>da', function()
  if vim.fn.filereadable(".vscode/launch.json") then
    local dap_vscode = require("dap.ext.vscode")
    dap_vscode.load_launchjs(nil, {
      ["pwa-node"] = js_based_languages,
      ["chrome"] = js_based_languages,
      ["pwa-chrome"] = js_based_languages
    })
  end
  require("dap").continue()
end)
