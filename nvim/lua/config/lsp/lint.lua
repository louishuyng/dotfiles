local lint = require('lint')

lint.linters_by_ft = {
  fish = { 'fish' },
  python = { 'ruff' },
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
