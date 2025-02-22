return {
  {
    'NLKNguyen/papercolor-theme',
    priority = 1000,
    config = function()
      -- Blank to address startup error
    end,
    init = function()
      vim.cmd [[
        source $VIMRUNTIME/colors/vim.lua
      ]]
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'PaperColor'
    end,
  },
  {
    'aikow/base.nvim',
    opts = {
      integrations = {
        "builtin.defaults",
        "builtin.git",
        "builtin.lsp",
        "builtin.semantic",
        "builtin.syntax",
        "builtin.terminal",
        "builtin.treesitter",
        "plugin.cmp",
        "plugin.devicons",
        "plugin.fzf-lua",
        "plugin.lualine",
        "plugin.indent-blankline",
        "plugin.luasnip",
        "plugin.mason",
        "plugin.mini",
        "plugin.telescope",
        "plugin.treesitter",
      },
    }
  },
}
