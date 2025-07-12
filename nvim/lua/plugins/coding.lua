return {
  -- CMP & Completion
  { 'hrsh7th/nvim-cmp' },
  {
    'L3MON4D3/LuaSnip',
    after = 'hrsh7th/nvim-cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.dotfiles/nvim/snippets' })

      require 'luasnip'.filetype_extend('ruby', { 'rails' })
    end,
  },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-nvim-lua' },
  { 'FelipeLema/cmp-async-path' },
  { 'hrsh7th/cmp-buffer', dependencies = { 'nvim-cmp' } },
  { 'hrsh7th/cmp-cmdline', dependencies = { 'nvim-cmp' } },

  -- Code Format
  { 'numToStr/Comment.nvim' },
  { 'kamykn/spelunker.vim' },

  -- Treesistter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require 'config.cores.treesitter'
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-context' },

  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>fd',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
    },
  },

  -- ROR
  -- { 'tpope/vim-rails' },

  -- Testing
  {
    'nvim-neotest/neotest',
    dependencies = {
      'folke/trouble.nvim',
      'nvim-neotest/nvim-nio',
      'nvim-neotest/neotest-jest',
      'fredrikaverpil/neotest-golang',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },

  -- Nvim on browser
  { 'glacambre/firenvim', build = ':call firenvim#install(0)' },

  -- Code runner
  {
    'CRAG666/code_runner.nvim',
    opts = {
      mode = 'vimux',
    },
    config = true,
    dependencies = {
      'preservim/vimux',
    },
  },
}
