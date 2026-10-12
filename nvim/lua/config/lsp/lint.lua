local lint = require('lint')

lint.linters_by_ft = {
  fish = { 'fish' },
  proto = { 'buf_lint' },
  python = { 'ruff' },
  swift = { 'swift_format' },
}

lint.linters.swift_format = {
  cmd = 'swift',
  stdin = true,
  append_fname = false,
  args = {
    'format',
    'lint',
    '--no-color-diagnostics',
    '--assume-filename',
    function()
      return vim.api.nvim_buf_get_name(0)
    end,
  },
  stream = 'stderr',
  ignore_exitcode = true,
  parser = require('lint.parser').from_errorformat('%f:%l:%c: %t%*[^:]: %m', { source = 'swift-format' }),
}

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
-- Removed BufEnter for performance - lint only on save and insert leave
local events = { 'BufWritePost', 'InsertLeave' }
vim.api.nvim_create_autocmd(events, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set('n', ',l', function()
  lint.try_lint()
end, { desc = 'Trigger linting for current buffer' })
