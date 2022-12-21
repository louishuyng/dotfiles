return {
  {"rafamadriz/friendly-snippets", event = "InsertEnter"}, {
    "hrsh7th/nvim-cmp",
    after = "friendly-snippets",
    config = function() require "config.cores.cmp" end
  }, {
    "L3MON4D3/LuaSnip",
    wants = "friendly-snippets",
    after = "nvim-cmp",
    config = function() require("config.libs.others").luasnip() end
  }, {"saadparwaiz1/cmp_luasnip", after = "LuaSnip"},
  {"hrsh7th/cmp-calc", after = "nvim-cmp"},
  {"hrsh7th/cmp-buffer", after = "nvim-cmp"}
}
