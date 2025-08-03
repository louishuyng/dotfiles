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
  { 'hrsh7th/cmp-buffer', dependencies = { 'nvim-cmp' } },
  { 'hrsh7th/cmp-cmdline', dependencies = { 'nvim-cmp' } },

  -- Code Format
  { 
    'numToStr/Comment.nvim',
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Treesistter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require 'config.cores.treesitter'
    end,
  },
  {
    'code-biscuits/nvim-biscuits',
    build = ':TSUpdate',
    config = function()
      require('nvim-biscuits').setup({
        toggle_keybind = '<leader>bb',
        cursor_line_only = true,
        show_on_start = false,
        default_config = {
          prefix_string = ' 🐿️ ',
        },
      })
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-context' },

  -- ROR
  -- { 'tpope/vim-rails' },

  -- Testing
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-neotest/neotest-jest',
      'fredrikaverpil/neotest-golang',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },

  -- Code runner
  {
    'michaelb/sniprun',
    branch = 'master',
    build = 'sh install.sh',
    config = function()
      require('sniprun').setup({})
    end,
  },
}
