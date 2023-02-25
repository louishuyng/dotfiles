return {
  {"rafamadriz/friendly-snippets", event = "InsertEnter"}, {
    "hrsh7th/nvim-cmp",
    dependencies = {"friendly-snippets"},
    config = function() require "config.cores.cmp" end
  }, {
    "L3MON4D3/LuaSnip",
    dependencies = {"nvim-cmp", "friendly-snippets"},
    config = function() require("config.libs.others").luasnip() end
  }, {"saadparwaiz1/cmp_luasnip", dependencies = {"LuaSnip"}},
  {"hrsh7th/cmp-calc", dependencies = {"nvim-cmp"}}, {"hrsh7th/cmp-nvim-lsp"},
  {"hrsh7th/cmp-buffer", dependencies = {"nvim-cmp"}}, {'github/copilot.vim'}
}
