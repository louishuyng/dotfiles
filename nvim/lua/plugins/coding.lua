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
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-nvim-lsp-signature-help' },
  { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
  { 'hrsh7th/cmp-buffer',                  dependencies = { "nvim-cmp" } },
  {
    'github/copilot.vim',
    event = "VeryLazy",
    cmd = "Copilot",
    build = "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash"
  },
  -- Code Format
  { 'hrsh7th/cmp-cmdline',  dependencies = { 'nvim-cmp' } },
  { 'numToStr/Comment.nvim' },
  { 'kamykn/spelunker.vim' },

  -- Treesistter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    config = function() require "config.cores.treesitter" end
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },

  -- ROR
  { 'tpope/vim-rails' },

  -- Testing
  { 'vim-test/vim-test',                          dependencies = { 'preservim/vimux' } },
}
