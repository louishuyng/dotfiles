-- Plugin management using Neovim 0.12's built-in vim.pack
-- Replaces lazy.nvim

vim.pack.add({
  -- Core dependencies
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/nvim-tree/nvim-web-devicons',

  -- Theme
  'https://github.com/catppuccin/nvim',
  'https://github.com/f-person/auto-dark-mode.nvim',

  -- UI
  'https://github.com/folke/snacks.nvim',
  'https://github.com/Bekaboo/dropbar.nvim',
  'https://github.com/akinsho/nvim-bufferline.lua',
  'https://github.com/DaikyXendo/nvim-material-icon',
  -- noice.nvim removed: vim._core.ui2 handles cmdline/messages in nvim 0.12
  'https://github.com/mrjones2014/smart-splits.nvim',
  'https://github.com/norcalli/nvim-colorizer.lua',
  'https://github.com/rcarriga/nvim-notify',
  'https://github.com/gen740/SmoothCursor.nvim',

  -- Editor
  'https://github.com/mg979/vim-visual-multi',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/dyng/ctrlsf.vim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/echasnovski/mini.bracketed',
  'https://github.com/echasnovski/mini.surround',
  'https://github.com/echasnovski/mini.pairs',
  'https://github.com/nvim-pack/nvim-spectre',
  'https://github.com/numToStr/Comment.nvim',
  'https://github.com/folke/trouble.nvim',
  'https://github.com/CRAG666/code_runner.nvim',
  'https://github.com/OXY2DEV/markview.nvim',

  -- Git
  'https://github.com/NeogitOrg/neogit',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/akinsho/git-conflict.nvim',

  -- Coding / Completion
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/saadparwaiz1/cmp_luasnip',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-buffer',
  'https://github.com/hrsh7th/cmp-cmdline',
  'https://github.com/hrsh7th/cmp-path',

  -- Treesitter
  -- NOTE: After first install run: :lua require('nvim-treesitter').install({})
  'https://github.com/nvim-treesitter/nvim-treesitter',

  -- Testing
  'https://github.com/preservim/vimux',
  'https://github.com/vim-test/vim-test',

  -- Navigation
  'https://github.com/nvim-telescope/telescope.nvim',
  -- NOTE: After first install, cd into the pack dir for this plugin and run: make
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-live-grep-args.nvim',
  'https://github.com/nvim-telescope/telescope-file-browser.nvim',
  'https://github.com/desdic/marlin.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/s1n7ax/nvim-window-picker',
  'https://github.com/folke/edgy.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/folke/flash.nvim',

  -- LSP
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/hedyhli/outline.nvim',
  'https://github.com/rachartier/tiny-inline-diagnostic.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/scalameta/nvim-metals',

  -- Debug
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/leoluz/nvim-dap-go',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',

  -- AI
  -- 'https://github.com/github/copilot.vim',
  -- 'https://github.com/NickvanDyke/opencode.nvim',
  'https://github.com/louishuyng/snipai',
})

vim.api.nvim_create_user_command('PackClean', function()
  local inactive = {}
  for _, p in ipairs(vim.pack.get()) do
    if not p.active then
      table.insert(inactive, p.spec.name)
    end
  end

  if #inactive == 0 then
    vim.notify('PackClean: no inactive plugins', vim.log.levels.INFO)
    return
  end

  local prompt = ('Remove %d inactive plugin(s)?\n  - %s\n\nProceed?'):format(
    #inactive,
    table.concat(inactive, '\n  - ')
  )
  if vim.fn.confirm(prompt, '&Yes\n&No', 2) == 1 then
    vim.pack.del(inactive)
    vim.notify(('PackClean: removed %d plugin(s)'):format(#inactive), vim.log.levels.INFO)
  end
end, { desc = 'Remove plugins not in vim.pack.add list' })
