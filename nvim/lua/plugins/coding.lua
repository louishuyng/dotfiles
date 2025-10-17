return {
  -- CMP & Completion
  { 'hrsh7th/nvim-cmp', lazy = false },
  {
    'L3MON4D3/LuaSnip',
    after = 'hrsh7th/nvim-cmp',
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
    priority = 1000,
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
  {
    'nvim-neotest/neotest',
    commit = '52fca6717ef972113ddd6ca223e30ad0abb2800c',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-jest',
      'fredrikaverpil/neotest-golang',
    },
  },
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
  -- Code runner
  {
    'CRAG666/code_runner.nvim',
    lazy = false,
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
