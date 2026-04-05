-- Load all plugins via vim.pack (replaces lazy.nvim)
require 'config.pack'

-- Theme (must be early, before other UI plugins)
require 'config.theme'

-- Mason (must be before LSP)
require('mason').setup()
require('mason-tool-installer').setup({
  ensure_installed = require('config.lsp.mason_packages'),
  auto_update = false,
  run_on_start = false,
})
-- Defer tool installation to avoid "press ENTER" on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.schedule(function()
      vim.cmd('MasonToolsInstall')
    end)
  end,
  once = true,
})

-- LSP (after mason)
require 'config.lsp'

-- Core plugin configs
require 'config.cores.treesitter'
require 'config.cores.cmp'
require 'config.cores.git'
require 'config.cores.snacks'
require 'config.cores.telescope'
require 'config.cores.test'
require 'config.cores.tree'
require 'config.cores.dap'

-- Library / misc plugin configs
require 'config.libs.aerial'
require 'config.libs.editor'
require 'config.libs.marlin'
require 'config.libs.metals'
require 'config.libs.multicursor'
-- noice.nvim removed: vim._core.ui2 handles cmdline/messages natively in 0.12
require 'config.libs.rest'
require 'config.libs.spectre'
