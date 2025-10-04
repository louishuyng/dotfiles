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
      'folke/lazydev.nvim',
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

  -- API Testing
  {
    'jellydn/hurl.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Optional, for markdown rendering with render-markdown.nvim
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown' },
        },
        ft = { 'markdown' },
      },
    },
    ft = 'hurl',
    opts = {
      -- Show debugging info
      debug = false,
      -- Show notification on run
      show_notification = false,
      -- Show response in popup or split
      mode = 'split',
      -- Default formatter
      formatters = {
        json = { 'jq' }, -- Make sure you have install jq in your system, e.g: brew install jq
        html = {
          'prettier', -- Make sure you have install prettier in your system, e.g: npm install -g prettier
          '--parser',
          'html',
        },
        xml = {
          'tidy', -- Make sure you have installed tidy in your system, e.g: brew install tidy-html5
          '-xml',
          '-i',
          '-q',
        },
      },
      -- Default mappings for the response popup or split views
      mappings = {
        close = 'q', -- Close the response popup or split view
        next_panel = '<C-n>', -- Move to the next response popup window
        prev_panel = '<C-p>', -- Move to the previous response popup window
      },
    },
    keys = {
      -- Run API request
      { '<leader>eA', '<cmd>HurlRunner<CR>', desc = 'Run All requests' },
      { '<leader>ea', '<cmd>HurlRunnerAt<CR>', desc = 'Run Api request' },
      { '<leader>ee', '<cmd>HurlRunnerToEntry<CR>', desc = 'Run Api request to entry' },
      { '<leader>eE', '<cmd>HurlRunnerToEnd<CR>', desc = 'Run Api request from current entry to end' },
      { '<leader>et', '<cmd>HurlToggleMode<CR>', desc = 'Hurl Toggle Mode' },
      { '<leader>ev', '<cmd>HurlVerbose<CR>', desc = 'Run Api in verbose mode' },
      { '<leader>eV', '<cmd>HurlVeryVerbose<CR>', desc = 'Run Api in very verbose mode' },
      -- Run Hurl request in visual mode
      { '<leader>e', ':HurlRunner<CR>', desc = 'Hurl Runner', mode = 'v' },
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
