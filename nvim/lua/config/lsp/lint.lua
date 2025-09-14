local lint = require('lint')

lint.linters_by_ft = {
  markdown = { 'markdownlint' },
  fish = { 'fish' },
  typesccript = { 'eslint' },
  typescriptreact = { 'eslint' },
  javascript = { 'eslint' },
  javascriptreact = { 'eslint' },
}

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
-- local events = { "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }
local events = { 'BufEnter', 'BufWritePost', 'InsertLeave' }
vim.api.nvim_create_autocmd(events, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set('n', ',l', function()
  lint.try_lint()
end, { desc = 'Trigger linting for current buffer' })
