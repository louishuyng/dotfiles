local metals_config

local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'scala', 'sbt', 'java' },
  callback = function()
    local metals = require('metals')
    if not metals_config then
      metals_config = metals.bare_config()
      metals_config.on_attach = function() end
    end
    metals.initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})
