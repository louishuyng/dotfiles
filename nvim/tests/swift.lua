-- Run from the repo root: nvim --headless -u NONE -i NONE -n -l nvim/tests/swift.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. '/nvim')
for _, plugin in ipairs({ 'nvim-lspconfig', 'cmp-nvim-lsp', 'nvim-lint', 'conform.nvim' }) do
  vim.cmd.packadd(plugin)
end
vim.cmd('filetype on')

require('config.lsp.lint')
require('config.lsp.on_attach')
require('config.lsp.register_formatters')
require('config/lsp/servers/swift')

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, 'p')
local filename = dir .. '/Swift check.swift'
vim.fn.writefile({ 'let value = 1', 'print(value)' }, filename)
vim.cmd.edit(vim.fn.fnameescape(filename))
vim.api.nvim_buf_set_lines(0, 0, 1, false, { 'let value=1' })

local ok, err = pcall(function()
  assert(vim.bo.filetype == 'swift', 'Swift filetype not detected')
  assert(
    vim.wait(15000, function()
      local clients = vim.lsp.get_clients({ bufnr = 0, name = 'sourcekit' })
      return clients[1] and clients[1].initialized
    end),
    'SourceKit-LSP did not attach'
  )
  assert(vim.fn.maparg('gf', 'n') ~= '', 'LSP keymaps missing')
  local client = vim.lsp.get_clients({ bufnr = 0, name = 'sourcekit' })[1]
  assert(client:supports_method('textDocument/completion'), 'LSP completion unavailable')
  local response = client:request_sync('textDocument/documentSymbol', {
    textDocument = vim.lsp.util.make_text_document_params(),
  }, 5000)
  assert(response and not response.err and response.result, 'SourceKit-LSP did not answer a symbol request')

  local lint = require('lint')
  local ns = lint.get_namespace('swift_format')
  vim.api.nvim_exec_autocmds('InsertLeave', {})
  assert(
    vim.wait(5000, function()
      return #vim.diagnostic.get(0, { namespace = ns }) > 0
    end),
    'Swift style diagnostics missing'
  )
  local diagnostic = vim.diagnostic.get(0, { namespace = ns })[1]
  assert(diagnostic.lnum == 0 and diagnostic.severity == vim.diagnostic.severity.WARN)

  vim.cmd.write()
  assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == 'let value = 1', 'Format on save failed')
  assert(
    vim.wait(5000, function()
      return #lint.get_running() == 0 and #vim.diagnostic.get(0, { namespace = ns }) == 0
    end),
    'Style diagnostics did not clear after formatting'
  )
end)

for _, client in ipairs(vim.lsp.get_clients()) do
  client:stop(true)
end
vim.fn.delete(filename)
vim.fn.delete(dir, 'd')
if not ok then
  io.stderr:write(tostring(err) .. '\n')
  vim.cmd('cquit')
end
print('Swift LSP, lint, and format-on-save checks passed')
vim.cmd('qa!')
