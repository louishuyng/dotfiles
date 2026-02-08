return {
  -- CMP & Completion (deferred to InsertEnter for faster startup)
  { 'hrsh7th/nvim-cmp', event = 'InsertEnter' },
  {
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-path',
    },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({ paths = '~/.dotfiles/nvim/snippets' })

      require 'luasnip'.filetype_extend('ruby', { 'rails' })
    end,
  },

  -- Code Format
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
  },

  -- Treesistter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    priority = 900,
    config = function()
      require 'config.cores.treesitter'
    end,
  },
  -- {
  --   'code-biscuits/nvim-biscuits',
  --   build = ':TSUpdate',
  --   event = { 'BufReadPost', 'BufNewFile' },
  --   config = function()
  --     require('nvim-biscuits').setup({
  --       toggle_keybind = '<leader>bb',
  --       cursor_line_only = true,
  --       show_on_start = false,
  --       default_config = {
  --         prefix_string = ' 🐿️ ',
  --       },
  --     })
  --   end,
  -- },
  -- { 'nvim-treesitter/nvim-treesitter-context', event = { 'BufReadPost', 'BufNewFile' } },

  -- ROR
  -- { 'tpope/vim-rails' },

  -- Testing
  { 'preservim/vimux' },
  {
    'vim-test/vim-test',
    dependencies = { 'preservim/vimux' },
    keys = {
      { '<space>tf', '<cmd>TestFile<cr>', desc = 'Test File' },
      { '<space>ts', '<cmd>TestNearest<cr>', desc = 'Test Nearest' },
      { '<space>tl', '<cmd>TestLast<cr>', desc = 'Test Last' },
      { '<space>ta', '<cmd>TestSuite<cr>', desc = 'Test Suite' },
      { '<space>tv', '<cmd>TestVisit<cr>', desc = 'Test Visit' },
    },
    config = function()
      require('config.cores.test')
    end,
  },
  {
    'folke/trouble.nvim',
    opts = {
      use_diagnostic_signs = true,
    }, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>fd',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
    },
  },
  -- Code runner
  {
    'CRAG666/code_runner.nvim',
    cmd = { 'RunCode', 'RunFile', 'RunProject' },
    config = function()
      require('code_runner').setup({
        filetype = {
          go = {
            'go run',
          },
        },
      })
    end,
  },
}
