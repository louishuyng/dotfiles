return {
  -- CMP & Completion
  { 'hrsh7th/nvim-cmp' },
  {
    'L3MON4D3/LuaSnip',
    after = 'hrsh7th/nvim-cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'saadparwaiz1/cmp_luasnip'
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.dotfiles/nvim/snippets" })

      require 'luasnip'.filetype_extend("ruby", { "rails" })
    end
  },
  { 'lukas-reineke/cmp-under-comparator' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer',                dependencies = { "nvim-cmp" } },
  { 'hrsh7th/cmp-cmdline',               dependencies = { 'nvim-cmp' } },

  -- Code Format
  { 'numToStr/Comment.nvim' },
  { 'kamykn/spelunker.vim' },

  -- Treesistter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    config = function() require "config.cores.treesitter" end
  },

  -- ROR
  -- { 'tpope/vim-rails' },

  -- Testing
  { 'vim-test/vim-test', dependencies = { 'preservim/vimux' } },
}
