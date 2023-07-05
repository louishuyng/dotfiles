local os_extend = require('utils.os_extend')

local top_level = os_extend.capture('git rev-parse --show-toplevel') .. "/src"
vim.cmd("autocmd BufEnter *.py let $PYTHONPATH='" .. top_level .. "'")
