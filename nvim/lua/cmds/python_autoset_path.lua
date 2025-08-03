local os_extend = require('utils.os_extend')

local top_level = os_extend.capture('git rev-parse --show-toplevel') .. "/src"

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = function()
    vim.env.PYTHONPATH = top_level
  end,
})
